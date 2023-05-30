# gptstudio 0.2.0

## Translations

The ChatGPT addin can now receive translations. If anyone wants to contribute with a new translation only needs to edit the translation file ("inst/translations/translation.json"). Currently supported languages are English and Spanish. 

## `{httr2}`

The requests are now handled with httr2 functions. This provides a more intuitive way to extend the functionality of the package, meaning that new request parameters to any endpoint are one pipe away from being implemented.

## Stream chat completions

Instead of waiting for the full response to be received before showing it to the user, the chat app now streams the response generation in real time. This makes for shorter wait times and removes the need to use `{waiter}`.

## Bug fixes

- The welcome message is no longer consumed by the chat history.
- Errors in requests now point to the OpenAI documentation.
-   In the chat app, removed unnecessary whitespace in the first line of code chunks.
-   In the chat app, the Enter key can now be used to send the user instruction as an alternative to clicking the "Send" button.
-   In the chat app, the copy button is now added via JS instead of a previous fragile R implementation. (by @idavydov)

## New look of the message history

Each individual message is now rounded and has an icon indicating whether it comes from the user or from the assistant. Each role has a different horizontal aligment and a slightly different background color.

![image](https://user-images.githubusercontent.com/19418298/233134945-06311099-92c0-4f4f-b728-66eb37f67836.png)

## Simplified user inputs

The prompt and buttons have been simplified to give the chat more room to expand.

![image](https://user-images.githubusercontent.com/19418298/233137057-7d0991d8-ab56-4b7f-ae93-e88cba41e600.png)

Now the app has a settings button where the user can still choose its skill level and prefered style.

![image](https://user-images.githubusercontent.com/19418298/233137374-4593410a-3132-4c1a-a886-5fd4966cb7e5.png)

## Welcome message with instructions

When the app starts (or history is cleared) the assistant greets the user with a random welcome message and instructions on how to use the app.

![image](https://user-images.githubusercontent.com/19418298/233138306-675e8693-e44a-4266-a293-070460e39e36.png)

## The chat can be adjusted vertically, horizontally and is scrollable

Limited to 800px width. The prompt input is always fixed to the bottom of the app.

<https://user-images.githubusercontent.com/19418298/233140923-5787ee5e-1042-4e84-8a42-6f1a55a47801.mp4>

## The chat inherits the current rstudio theme

This makes it look more integrated with the IDE, giving the feel of what an extension does in [VScode](https://code.visualstudio.com/).

<https://user-images.githubusercontent.com/19418298/233145316-5efe0e77-2192-48e6-97a1-02d87bd37255.mp4>

## Copy to clipboard button in code chunks

Every code chunk now has on top a bar indicating the language of the code displayed and a "Copy" button. When the user clicks the button writes the code in the clipboard and shows a short "Copied" feedback in the button.

## Custom scrollbar

The app uses now a narrower grey scrollbar.

# gptstudio 0.1.0

-   Added a `NEWS.md` file to track changes to the package.
