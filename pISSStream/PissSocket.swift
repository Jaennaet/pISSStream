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
        private let logger = Logger(
            subsystem: "social.bsky.jaennaet.StreamingPiss",
            category: "SubscriptionDelegate"
        )

        /// Stream to yield the piss tank value updates.
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)

        /// Closure to call when the connection status changes.
        private let onConnectionStatusChange: (Bool) -> Void

        /// Additional closure to handle signal status changes
        private let onSignalStatusChange: (Bool) -> Void

        init(appState: AppStateViewModel, 
             onConnectionStatusChange: @escaping (Bool) -> Void,
             onSignalStatusChange: @escaping (Bool) -> Void) {
            self.onConnectionStatusChange = onConnectionStatusChange
            self.onSignalStatusChange = onSignalStatusChange
            logger.debug("SubscriptionDelegateImpl.init()")
        }

        /// Handle the updates received from the subscription.
        func subscription(
            _ subscription: Subscription, didUpdateItem itemUpdate: ItemUpdate
        ) {
            /// Debug: Log all available fields
            logger.debug("Available fields: \(subscription.fields!.joined(separator: ", "))")
            
            /// Handle updates based on subscription type
            if subscription.items![0] == "TIME_000001" {
                /// Signal status update
                if let status = itemUpdate.value(withFieldName: "Status.Class") {
                    let hasSignal = status == "24"
                    logger.debug("Signal status update: \(status), hasSignal: \(hasSignal)")
                    onSignalStatusChange(hasSignal)
                }
            } else {
                /// Piss tank value update
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
            logger.error("Lost updates: \(lostUpdates) for item: \(itemName ?? "unknown")")
            onConnectionStatusChange(false)
        }

        func subscriptionDidRemoveDelegate(_ subscription: Subscription) {}

        func subscriptionDidAddDelegate(_ subscription: Subscription) {}

        func subscriptionDidSubscribe(_ subscription: Subscription) {}

        func subscription(
            _ subscription: Subscription, didFailWithErrorCode code: Int,
            message: String?
        ) {}

        func subscriptionDidUnsubscribe(_ subscription: Subscription) {}

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
    let stream: AsyncStream<String>
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
        stream = delegate.stream
        
        /// Thee delegate will be notified when new data arrives or when the connection status changes.
        pissTankSub.addDelegate(delegate)
        signalStatusSub.addDelegate(delegate)
        
        /// This line sends the subscription object to the client to be subscribed
        client.subscribe(pissTankSub)
        client.subscribe(signalStatusSub)
    }

    func pissStream() -> AsyncStream<String> {
        return stream
    }
}
