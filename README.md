## NotificationBar

Notification UI with alert and banner style. User can reply a message inside notification.

## Requirements

- iOS 8.0+ / Mac OS X 10.10+ / watchOS 2.0+ / tvOS 9.0+
- Swift 3
  - Xcode 8.0+

## Documentation

1. Add a handler:

    ```swift  
    NotificationBar.shared.selectHandler = { [weak self] _ in
    	guard let sSelf = self else { return }

    }
    NotificationBar.shared.sendHandler = { [weak self] (text) in
    	guard let sSelf = self else { return }

    	print(text)
    }
    ```

2. Show notification:

   ```swift
    NotificationBar.share.showNotification(title: "Notification", message: "Message", style: .banner)
    NotificationBar.share.showNotification(title: "Notification", message: "Message", style: .alert)
    ```