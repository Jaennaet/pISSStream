//
//  PissSocket.swift
//  pISSStream
//
//  Created by durul dalkanat on 12/25/24.
//

import BackgroundTasks
import LightstreamerClient
import os
import SwiftUI

actor PissSocket {
    let logger = Logger(
        subsystem: "social.bsky.jaennaet.pISSStream", category: "PissActor"
    )

    class SubscriptionDelegateImpl: SubscriptionDelegate {
        private let logger: Logger

        /// Stream to yield the piss tank value updates.
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)

        /// Closure to call when the connection status changes.
        private let onConnectionStatusChange: (Bool) -> Void

        /// Additional closure to handle signal status changes
        private let onSignalStatusChange: (String) -> Void

        init(
            appState: AppStateViewModel,
            onConnectionStatusChange: @escaping (Bool) -> Void,
            onSignalStatusChange: @escaping (Bool) -> Void
        ) {
            let logger = Logger(
                subsystem: "social.bsky.jaennaet.pISSStream",
                category: "SubscriptionDelegateImpl"
            )
            self.logger = logger

            var currentIsConnected = false
            self.onConnectionStatusChange = { isConnected in
                if isConnected != currentIsConnected {
                    logger.debug(
                        "Connection status update: \(isConnected)"
                    )
                    currentIsConnected = isConnected
                    onConnectionStatusChange(isConnected)
                }
            }

            var currentSignalStatus = "1"
            self.onSignalStatusChange = { signalStatus in
                if signalStatus != currentSignalStatus {
                    let hasSignal = signalStatus == "24"
                    logger.debug(
                        "Signal status update: \(signalStatus), hasSignal: \(hasSignal)"
                    )
                    currentSignalStatus = signalStatus
                    onSignalStatusChange(hasSignal)
                }
            }

            logger.debug("SubscriptionDelegateImpl.init()")
        }

        /// Handle the updates received from the subscription.
        func subscription(
            _ subscription: Subscription, didUpdateItem itemUpdate: ItemUpdate
        ) {
            /// The logs show that we're getting two different types of updates with different field sets: TIME_000001 and NODE3000005.
            /// Debug: Log all available fields
            logger.debug(
                "Updating subscription: \(subscription.printableItems), available fields: \(subscription.fields!.joined(separator: ", "))"
            )

            /// Handle updates based on subscription type
            /// Signal status tracking via a new subscription to TIME_000001
            /// Signal status update: TimeStamp, Status.Class, Status
            if subscription.items![0] == "TIME_000001" {
                /// Signal status update
                if let status = itemUpdate.value(withFieldName: "Status.Class") {
                    onSignalStatusChange(status)
                }
            } else {
                /// Piss tank value update: Value, Status, TimeStamp
                if let value = itemUpdate.value(withFieldName: "Value") {
                    let newValue = value + "%"
                    logger.debug("received value update: \(newValue)")
                    continuation.yield(newValue)
                } else {
                    logger.error("Failed to get Value field")
                    continuation.yield("N/A%")
                }
            }
        }

        func subscription(
            _ subscription: Subscription,
            didClearSnapshotForItemName itemName: String?, itemPos: UInt
        ) {}

        func subscription(
            _ subscription: Subscription, didLoseUpdates lostUpdates: UInt,
            forCommandSecondLevelItemWithKey key: String
        ) {}

        func subscription(
            _ subscription: Subscription, didFailWithErrorCode code: Int,
            message: String?, forCommandSecondLevelItemWithKey key: String
        ) {}

        func subscription(
            _ subscription: Subscription,
            didEndSnapshotForItemName itemName: String?,
            itemPos: UInt
        ) {}

        /// Handle the loss of updates.
        func subscription(
            _ subscription: Subscription, didLoseUpdates lostUpdates: UInt,
            forItemName itemName: String?, itemPos: UInt
        ) {
            logger.error(
                "Lost updates: \(lostUpdates) for item: \(itemName ?? "unknown")"
            )
            onConnectionStatusChange(false)
        }

        func subscriptionDidRemoveDelegate(_ subscription: Subscription) {}

        func subscriptionDidAddDelegate(_ subscription: Subscription) {}

        func subscriptionDidSubscribe(_ subscription: Subscription) {
            logger.debug("subscribed to: \(subscription.printableItems)")
            onConnectionStatusChange(true)
        }

        func subscription(
            _ subscription: Subscription, didFailWithErrorCode code: Int,
            message: String?
        ) {
            logger.error(
                "subscription to: \(subscription.printableItems) failed with error message: \"\(message ?? "")\" code: \(code)"
            )
            onConnectionStatusChange(false)
        }

        func subscriptionDidUnsubscribe(_ subscription: Subscription) {
            logger.debug("unsubscribed from: \(subscription.printableItems)")
            onConnectionStatusChange(false)
        }

        func subscription(
            _ subscription: Subscription,
            didReceiveRealFrequency frequency: RealMaxFrequency?
        ) {}
    }

    let client: LightstreamerClient = .init(
        serverAddress: "https://push.lightstreamer.com",
        adapterSet: "ISSLIVE"
    )

    /// Stream to yield the piss tank value updates of type String.
    /// Asynchronous streams allow the code to receive data as it becomes available without blocking the main thread.
    let pissStream: AsyncStream<String>
    init(appState: AppStateViewModel) {
        ///  It logs a message indicating that the initializer has been called.
        logger.debug("PissActor.init()")

        /// Connect to the Lightstreamer server.
        client.connect()

        /// Create both subscriptions with all required fields
        let pissTankSub = Subscription(
            subscriptionMode: .MERGE,
            items: ["NODE3000005"],
            fields: ["Value", "Status", "TimeStamp"]
        )

        let signalStatusSub = Subscription(
            subscriptionMode: .MERGE,
            items: ["TIME_000001"],
            fields: ["TimeStamp", "Status.Class", "Status"]
        )

        /// SubscriptionDelegateImpl acts as a delegate, receiving data from the subscription and performing actions on it.
        /// Reactive Programming: The use of a data stream and the event-based onConnectionStatusChange closure have a reactive feel to them. When data becomes available, it automatically triggers updates.
        let delegate = SubscriptionDelegateImpl(
            appState: appState,
            onConnectionStatusChange: { isConnected in
                Task { @MainActor in //  This creates a new asynchronous task to perform the given closure on the main actor.
                    appState.isConnected = isConnected
                }
            },
            onSignalStatusChange: { hasSignal in
                Task { @MainActor in
                    appState.hasSignal = hasSignal
                }
            }
        )

        /// Add the delegate to the subscription.
        pissStream = delegate.stream

        /// Thee delegate will be notified when new data arrives or when the connection status changes.
        pissTankSub.addDelegate(delegate)
        signalStatusSub.addDelegate(delegate)

        /// This line sends the subscription object to the client to be subscribed
        client.subscribe(pissTankSub)
        client.subscribe(signalStatusSub)
    }
}

private extension Subscription {
    var printableItems: String {
        (items ?? []).joined(separator: ",")
    }
}
