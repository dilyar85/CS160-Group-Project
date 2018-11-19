//
//  DispatchUtil.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation

func runOnMainThread(work: @escaping () -> ()) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}

func delay(_ time: TimeInterval, queue: DispatchQueue = DispatchQueue.main, work: @escaping () -> ()) {
    guard time > 0 else {
        work()
        return
    }
    queue.asyncAfter(deadline: .now() + time, execute: work)
}

func synchronize(lock: Any, work: () -> ()) {
    objc_sync_enter(lock)
    work()
    objc_sync_exit(lock)
}



