{after, assert, clickElement, defer, dragToCoordinates, moveCursor, pressKey, test, testGroup, triggerEvent, typeCharacters} = Trix.TestHelpers

testGroup "Attachments", template: "editor_with_image", ->
  test "moving an image by drag and drop", (expectDocument) ->
    typeCharacters "!", ->
      moveCursor direction: "right", times: 1, (coordinates) ->
        img = document.activeElement.querySelector("img")
        triggerEvent(img, "mousedown")
        defer ->
          dragToCoordinates coordinates, ->
            expectDocument "!a#{Trix.OBJECT_REPLACEMENT_CHARACTER}b\n"

  test "removing an image", (expectDocument) ->
    after 20, ->
    closeButton = findElement(".#{Trix.config.css.classNames.attachment.removeButton}")
    clickElement closeButton, ->
      expectDocument "ab\n"

getFigure = ->
  findElement("figure")

findElement = (selector) ->
  getEditorElement().querySelector(selector)

getCaptionContent = (element) ->
  element.textContent or getPseudoContent(element)


getPseudoContent = (element) ->
  before = getComputedStyle(element, "::before").content
  after = getComputedStyle(element, "::after").content

  content =
    if before and before isnt "none"
      before
    else if after and after isnt "none"
      after
    else
      ""

  content.replace(/^['"]/, "").replace(/['"]$/, "")
