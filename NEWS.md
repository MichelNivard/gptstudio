# gptstudio (development version)

- Fixed a bug that showed the message "ChatGPT responded" even when other service was being used in "Chat in source" related addins. #213
- Added claude-3.5-sonnet model from Anthropic.
- Set gpt-4o-mini as default model for OpenAI. #219
- Fixed bugs with Azure OpenAI service. #223
- Add audio input option for chat app. #224
- Fix bug with chat app not loading on linux. #224
- Allow chat app to run in Positron (not yet as background job) #224
- API calls now run async with ExtendedTask. #224
- New styling of chat app. #224
- Add code syntax highlighting to chat app. #224
- Replace curl calls with httr2. #224
- Replace %>% with |>, bump min R to >=4.1, remove revdep folder. #226

## gptstudio 0.4.0

This release introduces several exciting enhancements. The chat app now features a sidebar for conversation history, new chats, and settings, along with helpful tooltips. Additionally, local models are now supported using ollama, and the Perplexity Service offers various models like llama-3-sonar and mixtral-8x7b. Cohere Service, with models such as command and command-light, is also available. Internally, there are improvements, bug fixes, and quality-of-life enhancements.

### UI updates

- The chat app has now a sidebar where users can see their conversation history, start new chats and change the settings. Because of this, the chat interface has more room for showing messages.
- All chats are saved and automatically updated after every assistant's message. They are created with a placeholder title built using the first user message in the conversation. Titles are editable and users are able to delete any conversation (or all of them at once).
- We have a shorter welcome message, but we have added lots of tooltips to help with navigation.

### Local models

We are happy to announce that we now support local models with [ollama](https://github.com/ollama/ollama). By default we look for the ollama host in `http://localhost:11434` but this can be customized by setting up the `OLLAMA_HOST` environmental variable. Be aware that you are in charge of maintaining your own ollama installation and models.

### Perplexity Service

Perplexity AI now offers a wide range of models as part of their service. The current version includes the following models: llama-3-sonar-small-32k-chat, llama-3-sonar-small-32k-online, llama-3-sonar-large-32k-chat, llama-3-sonar-large-32k-online, llama-3-8b-instruct, llama-3-70b-instruct, mixtral-8x7b-instruc". See Perplexity API documentation for more information on these models.

### Cohere Service

Cohere is now available as another service. The current version includes the following models: command, command-light, command-nightly, and command-light-nightly. See [Cohere's docs](https://docs.cohere.com/ ) for more on these models and capabilities.

### Internal

- Reverted back to use an R6 class for OpenAI streaming (which now inherits from `SSEparser::SSEparser`). This doesn't affect how the users interact with the addins, but avoids a wider range of server errors.
- We now make heavy use of `{lintr}` for keeping code consistency.
- Fixed a bug in retrieval of OpenAI models
- Fixed a bug in Azure OpenAI request formation.
- Fixed a bug in "in source" calls for addins.
- Fixed a bug that showed a "Connection refused" message in the viewer in unix platforms. Fix #179
- The chat addin no longer closes itself when an OpenAI api key is not detected.
- Converted from PALM to Google for Google AI Studio models.
- Updated Anthropic models with with their claude-3 update.
- More bug fixes with Azure OpenAI with request body structure and using token + api key.
- Any scrollbar now has 5px for width and height. This allows for more room when using the viewer panel.
- `{gptstudio}` now requires `{bslib}` v0.6.0 or greater, to take advantage of the sidebar styling.
- Updated anthropic API calls to use new messages endpoint.
- Fixed a bug in Anthropic chats to now include history.
- OpenAI stream no longer hangs with error "Argument has length 0". #199
- In source calls no longer attempt to evaluate R code. #203

### Quality of Life Improvements and Documentation

- Chat in source now respects the model selection that you set using the Chat addin.
- A new function `gpstudio_sitrep()` has been added to help with debugging and setup.
- API checking is now done for each available service, including local models.
- New vignettes were added to setup each service.

## gptstudio 0.3.1

* Better API checking to direct users to .Renviron to set API key to be persistent across sessions

## gptstudio 0.3.0

### Persistent Config File

We've introduced a configuration file that persists across sessions. Now, your preferred app settings will be loaded each time you launch the app, making it even more user-friendly.

### Custom Prompt Selection

Further enhancing customization, we've added a "task" option that lets you choose the system prompt from options such as "coding", "general", "advanced developer", and "custom". The "custom" option allows you to replace the system prompt instructions entirely.

### Expanded API Services

We're excited to announce that our service now includes models from HuggingFace's inference API, Anthropic's claude models, and Google's MakerSuite, and Azure OpenAI service broadening the range of AI solutions you can use.

### S3 Class for API Services

In an effort to make future API additions easier, API calls now use S3 classes.

### Real-time Streaming Updates

Inspired by Edgar Ruiz's work on [chattr](https://github.com/mlverse/chattr), we've implemented real-time streaming without relying on R6, but this will receive more attention in the 0.4.0 release.

### Model Selection Feature

The ChatGPT add-in now comes with an integrated model selection feature, enabling you to choose any chat completion model that matches either gpt-3.5 or gpt-4 in the model name.

### Upgraded Add-ins

The add-ins for code commenting and spelling & grammar checking have been upgraded to use the chat/completions endpoint and now default to the gpt-3.5-turbo model. You can modify this default setting as needed.

### Custom OpenAI Base Url

You now have the option to specify a different base url for the OpenAI API. A much-requested feature by our users, this addition helps in tailoring the API access to suit your needs.

### Bug Fixes

We've addressed several issues in this update. Now, the "Spelling and Grammar" and "Comment your code" add-ins can successfully insert text in source. Also, installation issues related to the {stringr} package and compatibility with earlier versions of R have been resolved.

### Improved Compatibility Checks

To ensure optimal user experience, we're now using GitHub Actions to check compatibility with a wider range of R versions on Ubuntu.

We hope you enjoy the enhanced features and improved performance in this latest version. As always, your feedback is invaluable to us, so please keep it coming!

### Translations

The ChatGPT addin can now speak German! Thanks to [Mark Colley](https://github.com/M-Colley) #107

## gptstudio 0.2.0

### Translations

The ChatGPT addin can now receive translations. If anyone wants to contribute with a new translation only needs to edit the translation file ("inst/translations/translation.json"). Currently supported languages are English and Spanish. 

### `{httr2}`

The requests are now handled with httr2 functions. This provides a more intuitive way to extend the functionality of the package, meaning that new request parameters to any endpoint are one pipe away from being implemented.

### Stream chat completions

Instead of waiting for the full response to be received before showing it to the user, the chat app now streams the response generation in real time. This makes for shorter wait times and removes the need to use `{waiter}`.

### Bug fixes

- The welcome message is no longer consumed by the chat history.
- Errors in requests now point to the OpenAI documentation.
-   In the chat app, removed unnecessary whitespace in the first line of code chunks.
-   In the chat app, the Enter key can now be used to send the user instruction as an alternative to clicking the "Send" button.
-   In the chat app, the copy button is now added via JS instead of a previous fragile R implementation. (by @idavydov)

### New look of the message history

Each individual message is now rounded and has an icon indicating whether it comes from the user or from the assistant. Each role has a different horizontal alignment and a slightly different background color.

![image](https://user-images.githubusercontent.com/19418298/233134945-06311099-92c0-4f4f-b728-66eb37f67836.png)

### Simplified user inputs

The prompt and buttons have been simplified to give the chat more room to expand.

![image](https://user-images.githubusercontent.com/19418298/233137057-7d0991d8-ab56-4b7f-ae93-e88cba41e600.png)

Now the app has a settings button where the user can still choose its skill level and preferred style.

![image](https://user-images.githubusercontent.com/19418298/233137374-4593410a-3132-4c1a-a886-5fd4966cb7e5.png)

### Welcome message with instructions

When the app starts (or history is cleared) the assistant greets the user with a random welcome message and instructions on how to use the app.

![image](https://user-images.githubusercontent.com/19418298/233138306-675e8693-e44a-4266-a293-070460e39e36.png)

### The chat can be adjusted vertically, horizontally and is scrollable

Limited to 800px width. The prompt input is always fixed to the bottom of the app.

<https://user-images.githubusercontent.com/19418298/233140923-5787ee5e-1042-4e84-8a42-6f1a55a47801.mp4>

### The chat inherits the current rstudio theme

This makes it look more integrated with the IDE, giving the feel of what an extension does in [VScode](https://code.visualstudio.com/).

<https://user-images.githubusercontent.com/19418298/233145316-5efe0e77-2192-48e6-97a1-02d87bd37255.mp4>

### Copy to clipboard button in code chunks

Every code chunk now has on top a bar indicating the language of the code displayed and a "Copy" button. When the user clicks the button writes the code in the clipboard and shows a short "Copied" feedback in the button.

### Custom scrollbar

The app uses now a narrower grey scroll bar.

## gptstudio 0.1.0

-   Added a `NEWS.md` file to track changes to the package.
