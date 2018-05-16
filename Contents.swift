//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//extension Array {
//    func concurrentMap(givenIndices: (Int) -> Void) {
//        // This is function is used to concurrently map through an array
//        // When we have the array that the user wants we concurrently iterate though it
//
//        let resultArray = [Any](repeating: 0, count: self.count)
//
//        // Now that we have the results arrray what we can do is that we can now iterate though the array concurrently
//        DispatchQueue.concurrentPerform(iterations: resultArray.count) { (index) in
//            givenIndices(index)
//        }
//    }
//}


let numbers = [0,1,2,4,5,6, 67, 87, 89, 23, 34, 12, 67]
//print(numbers.map({return $0 * 2}))


// SO the goal of this function is that it transforms the elements into a type for example if I have an array of words map through the array and transform into lowercase
extension Array {
    
    // Take in an sequence of elements that return anything as a map function would do then the function returns an array of any data type
    func parallelMap<T>(_ transform: (Element) -> T)  -> [T] {
        // Concurrently perform operations of map
        var resultArray = Array<T?>.init(repeating: nil, count: self.count)
        
        let serialQueue = DispatchQueue(label: "AssignmentQueue")
        // Taking each element at the index in the results arrray and transform that element to the type that the user wants
        DispatchQueue.concurrentPerform(iterations: resultArray.count) { (index) in
            
            // Concurrently transforming each element can cause a race condition when assigning therefore have to perform this synchronously
            serialQueue.sync {
                resultArray[index] = transform(self[index])
            }
            
        }
        
        // After the transformations are set to the results array we return the new array
        return resultArray as! [T]
    }
}

print(numbers.parallelMap({$0 * 4}))




// Instantiating a higher priority queue
let higherPriority = DispatchQueue.global(qos: .userInitiated)

// Instantiating a lower priority queue
let lowerPriority = DispatchQueue.global(qos: .background)

// Creating a sempahore with a value of 1 which means only one thread can have access when the lock is put on the critical section
let semaphore = DispatchSemaphore(value: 1)


func semaphoreUse(queue: DispatchQueue, symbol: String) {
    var emptyArray = Array<String>.init(repeating: "", count: 10)
    queue.async {
        
        // Requesting the resources, checks to see if we the counter for the semaphore is above zero if it is then it decrements the counter meaning that 0 threads have access to the critical section and puts a lock on it now that the counter on 0
        semaphore.wait()
         print("\(emptyArray) requesting")
        
        
        for i in 0 ... emptyArray.count {
            // Read operation however with out the
            emptyArray[i] = symbol
            
        }

        semaphore.signal()
        // If you never release the lock then the next operation can not occur deadlock? Has to wait until the first thread is done with the tasks
        print("\(emptyArray) release") // Prints when the thread is released from the lock to show that another thread is ready to access the critical section
    }
}
semaphoreUse(queue: lowerPriority, symbol: "🤪") // When switching priorities calling the lower priority acquires the lock first using priority inversion
semaphoreUse(queue: higherPriority, symbol: "😭")

//let dispatchWorkItem = DispatchWorkItem(qos: .userInitiated, flags: .barrier) {
//    // So first thing first let us go over the initalizers for the Dispatch Work item first we have to declare the quality of service which determines the priority level of the queue and by adding a barrier flag what we are essentially doing is making sure that this task is not executed in parallel on a concurrent queue and for a serial queue it would have no affect
//    
//    // The purpose of this work item what we are doing is that we are going to perform an operation that we are going to be locking
//    
//}





