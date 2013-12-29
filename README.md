# Lights-iOS

Lights-iOS is an iOS app built on top of my [LightsKit](https://github.com/edc1591/LightsKit/) framework for controlling X10 devices and RGB LEDs.

## Links

* Documentation: <http://edc.me/lights/documentation.html>
* Lights-rails app: <https://github.com/edc1591/lights-rails>
* Lights bridge apps: <https://github.com/edc1591/lights-bridge>

## Installation

Lights-iOS uses CocoaPods for dependencies. To install CocoaPods run the following from the Lights-iOS directory.

    $ sudo gem install cocoapods
    
Then run the following to install the dependencies.

    $ pod install


## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Dependencies

Tool                    | Description
----------------------- | -----------
[BlocksKit]             | Objective-C block utilities
[SSKeychain]            | Objective-C Keychain wrapper

[BlocksKit]: https://github.com/pandamonia/BlocksKit
[SSKeychain]: https://github.com/soffes/sskeychain

## License

Copyright (c) 2014 Evan Coleman, released under the [MIT license](LICENSE).