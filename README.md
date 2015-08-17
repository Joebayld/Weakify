# Weakify

[![CI Status](http://img.shields.io/travis/klundberg/Weakify.svg?style=flat)](https://travis-ci.org/klundberg/Weakify)
[![Version](https://img.shields.io/cocoapods/v/Weakify.svg?style=flat)](http://cocoapods.org/pods/Weakify)
[![License](https://img.shields.io/cocoapods/l/Weakify.svg?style=flat)](http://cocoapods.org/pods/Weakify)
[![Platform](https://img.shields.io/cocoapods/p/Weakify.svg?style=flat)](http://cocoapods.org/pods/Weakify)

## How it works

Weakify is a µframework providing some commonly useful variations of the `weakify()` function. `weakify()` is primarily a way to be able to use a method on a class as a "closure" value that would be managed by some other component, but in a way that prevents memory leaks from occurring.

If you were to define a class like this:

```swift
class Thing {
    func doSomething() {
        print("Something!")
    }

    var callback: () -> Void = {}
    
    func registerCallback() {
        callback = self.doSomething
    }
}

let thing = Thing()
thing.registerCallback()
```

You would be creating a retain cycle, and `thing` would never be deallocated. Whenever you reference a method on an object without calling it, the instance of the class that the method is bound to is captured by the method for the lifetime of the method reference. This is because in Swift instance methods are effectively curried functions: the actual methods you write on classes and instances close over references to self (strongly) so that those references are guaranteed to live for the lifetime of the method.

You can get around this by doing the following in the registerCallback method:

```swift
func registerCallback() {
	callback = { [weak self] in
		self?.doSomething()
	}
}
```

which breaks the retain cycle. However, having to create a new closure whenever you want to do this is a little bit cumbersome, which is where `weakify()` comes in. Using it, you can rewrite this method like so:

```swift
func registerCallback() {
	callback = weakify(self, self.dynamicType.doSomething)
}
```

weakify separates the instance of the object from the method using static method references (you can reference the `doSomething` method statically with `Thing.doSomething` or `self.dynamicType.doSomething`, which has a type of `(Thing) -> () -> ()`). In this example `weakify` weakly applies self to the curried function's first argument, returning a closure that has the type `() -> ()` which, when called, will execute the doSomething method *only if `self` has not been deallocated* (much like the manual closure that weakly captures self defined earlier).

## Usage

There are a few variants of weakify available in this library for you to use:

```swift
func weakify <T: AnyObject, U>(owner: T, f: T->()->()) -> U -> ()
```
may be applied to any method that takes no arguments and returns none. The resulting closure can accept an argument which will simply be ignored (useful in cases like `NSNotificationCenter` when you don't care about the `notification` argument), or the type may also represent `Void`, meaning no input arguments are necessary.

```swift
func weakify <T: AnyObject, U>(owner: T, f: T->U->()) -> U -> ()
```
may be applied to a method that accepts an argument and returns none, which the resulting closure mirrors.

```swift
func weakify <T: AnyObject, U>(owner: T, f: T->()->U) -> () -> U?
```
may be applied to a function that returns some value. The resulting closure must return optional, since if owner is deallocated before it is called there's nothing else it can return.

```swift
func weakify <T: AnyObject, U, V>(owner: T, f: T->U->V) -> U -> V?
```
may be applied to a function that accepts and returns something; effectively a union of the two previous cases.

```swift
func weakify <T: AnyObject, U, V>(owner: T, f: T->U?->()) -> V -> ()
```
may be applied to a function that accepts an optional value. The resulting closure can have a completely different type for the input argument. If `owner` is not `nil` at call time, the argument to the resulting closure is conditionally cast from `V` to `U` with the `as?` operator, and the result of that is passed to the original function (which is why it must accept an optional, in case the cast fails).

## Requirements

* Supported on Xcode 6.3+/Swift 1.2
* iOS 8+/OS X 10.9+

## Installation

### Cocoapods
Weakify is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Weakify", "~> 0.1"
```

### Manual installation
If you cannot use cocoapods (if you still need to target iOS 7 at a minimum for instance), the recommended way to install this is to simply manually copy weakify.swift from the repo into your project. You may also opt to reference this repo as a git submodule, which is an exercise I leave to you.

## TODO

* Swift 2 support (for methods that throw!)

## Author

Kevin Lundberg, kevin@klundberg.com

## Contributions
If you have additional variants of weakify you'd like to see, feel free to submit a pull request! Please include Quick-based unit tests with any changes.

## License

Weakify is available under the MIT license. See the LICENSE file for more info.
