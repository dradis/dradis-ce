class @TagArea
	constructor: (@tagContainer) ->
		@input = @tagContainer.querySelector('textarea')
		@tagList = document.querySelector('#issue_tag_list')
		@tags = []

		if @tagList.value.length > 1
			@tags = @tagList.value.split(', ')

		@input.addEventListener 'keyup', @_inputListener
		@_addTags()

	_inputListener: (e) =>
		if e.key == 'Enter'
			for tag in e.target.value.split(',')
				@tags.push(tag.trim())

			@_addTags()
			@_updateTagList()
			@input.value = ''

	_clearTags: ->
		for tag in $('.tag')
			tag.parentElement.removeChild(tag)

	_addTags: ->
		@_clearTags()
		for tag in @tags.slice().reverse()
			@tagContainer.prepend(@_createTag(tag))

	_updateTagList: =>
		@tagList.value = @tags.join(', ')
		changeEvent = new Event('change')
		@tagList.dispatchEvent(changeEvent)

	_removeTagListener: (e) =>
		@tags = @tags.filter((tag) -> tag != e.target.dataset.item)
		@_updateTagList()
		e.target.parentElement.remove()

	_createTag: (label) ->
		div = document.createElement('div')
		div.setAttribute('class', 'tag')
		span = document.createElement('span')
		span.innerHTML = label
		closeIcon = document.createElement('i')
		closeIcon.setAttribute('class', 'fa fa-close')
		closeIcon.setAttribute('data-item', label)
		div.appendChild(span)
		div.appendChild(closeIcon)
		closeIcon.addEventListener 'click', @_removeTagListener

		return div

document.addEventListener "turbolinks:load", ->
	tagContainer = document.querySelector('.tag-container')

	if tagContainer
		new TagArea(tagContainer)
