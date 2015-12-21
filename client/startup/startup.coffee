Meteor.startup ->
	TimeSync.loggingEnabled = false

	UserPresence.awayTime = 300000
	UserPresence.start()
	Meteor.subscribe("activeUsers")

	Session.setDefault('AvatarRandom', 0)

	window.lastMessageWindow = {}
	window.lastMessageWindowHistory = {}

	@defaultUserLanguage = ->
		lng = window.navigator.userLanguage || window.navigator.language || 'en'
		# Fix browsers having all-lowercase language settings eg. pt-br, en-us
		re = /([a-z]{2}-)([a-z]{2})/
		if re.test lng
			lng = lng.replace re, (match, parts...) -> return parts[0] + parts[1].toUpperCase()
		return lng

	loadedLaguages = []

	setLanguage = (language) ->
		if loadedLaguages.indexOf(language) > -1
			return

		loadedLaguages.push language

		language = language.split('-').shift()
		TAPi18n.setLanguage(language)

		language = language.toLowerCase()
		if language isnt 'en'
			Meteor.call 'loadLocale', language, (err, localeFn) ->
				Function(localeFn)()
				moment.locale(language)

	setFontSize = (size) ->
		console.log "Set my SIZE= ", size
		$('message body').css 'font-size', "#{size}"

	Tracker.autorun (c) ->
		if Meteor.user()?.language?
			c.stop()

			if localStorage.getItem('userLanguage') isnt Meteor.user().language
				localStorage.setItem("userLanguage", Meteor.user().language)
				setLanguage Meteor.user().language
				if isRtl localStorage.getItem "userLanguage"
					$('html').addClass "rtl"

	Tracker.autorun (c) ->
		if Meteor.user()?.settings?.preferences?.userFontSize?
			#c.stop()

			console.log "REAL SAVED SIZE= ", Meteor.user().settings.preferences.userFontSize

			if localStorage.getItem('userFontSize') isnt Meteor.user().settings.preferences.userFontSize
				localStorage.setItem("userFontSize", Meteor.user().settings.preferences.userFontSize)
				setFontSize Meteor.user().settings.preferences.userFontSize
				console.log "We set the REAL SIZE....xxxx "

	userLanguage = localStorage.getItem("userLanguage")
	userLanguage ?= defaultUserLanguage()

	setLanguage userLanguage

	userFontSize = localStorage.getItem("userFontSize")
	userFontSize ?= '100%'

	setFontSize userFontSize
	
	console.log "SAVED SIZE= ", userFontSize

