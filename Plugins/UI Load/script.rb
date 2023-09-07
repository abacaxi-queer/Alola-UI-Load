module UILoad
	# If true, player name will be blue if male, red if female
	SHOW_GENDER_COLOR = true
	# If true, it'll use a custom font from Fonts folder
	USE_CUSTOM_FONT = false
	# Define a custom font name here (it must exist in Fonts folder)
	CUSTOM_FONT_NAME = "FOT-Rodin Pro" 
	# Define a custom font size here
	CUSTOM_FONT_SIZE = 24
end

class PokemonLoadPanel < Sprite

	def refresh
    return if @refreshing
    return if disposed?
    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = Bitmap.new(@bgbitmap.width, 222)
      pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
      @refreshBitmap = false
      self.bitmap&.clear
      if @isContinue
        self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, (@selected) ? 222 : 0, @bgbitmap.width, 222))
      else
        self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, 444 + ((@selected) ? 46 : 0), @bgbitmap.width, 46))
      end
      textpos = []
      if @isContinue
        textpos.push([@title, 204, 36, :center, TEXT_SHADOW_COLOR, TEXT_COLOR])
        #textpos.push([_INTL("Badges:"), 140, 102, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
        #textpos.push([@trainer.badge_count.to_s, 310, 102, :right, TEXT_SHADOW_COLOR, TEXT_COLOR])
        textpos.push([_INTL("Pokédex:"), 140, 128, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
        textpos.push([@trainer.pokedex.seen_count.to_s, 310, 128, :right, TEXT_SHADOW_COLOR, TEXT_COLOR])
        textpos.push([_INTL("Play time:"), 140, 155, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
        hour = @totalsec / 60 / 60
        min  = @totalsec / 60 % 60
        if hour > 0
          textpos.push([_INTL("{1}h {2}m", hour, min), 310, 155, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
        else
          textpos.push([_INTL("{1}m", min), 310, 155, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
        end
		if UILoad::SHOW_GENDER_COLOR
			if @trainer.male?
			  textpos.push([@trainer.name, 140, 75, :left, MALE_TEXT_COLOR, MALE_TEXT_SHADOW_COLOR])
			elsif @trainer.female?
			  textpos.push([@trainer.name, 140, 75, :left, FEMALE_TEXT_COLOR, FEMALE_TEXT_SHADOW_COLOR])
			else
			  textpos.push([@trainer.name, 140, 75, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
			end
		else
			textpos.push([@trainer.name, 140, 75, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
		end    
        mapname = pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/, @trainer.name)
        textpos.push([mapname, 140, 102, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
      else
        textpos.push([@title, 32, 14, :left, TEXT_SHADOW_COLOR, TEXT_COLOR])
      end
	  self.bitmap.font.name = UILoad::CUSTOM_FONT_NAME if UILoad::USE_CUSTOM_FONT
	  self.bitmap.font.size = UILoad::CUSTOM_FONT_SIZE if UILoad::USE_CUSTOM_FONT
      pbDrawTextPositions(self.bitmap, textpos)
    end
    @refreshing = false
  end

end

class PokemonLoad_Scene

	def pbStartScene(commands, show_continue, trainer, stats, map_id)
		@commands = commands
		@sprites = {}
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99998
		addBackgroundOrColoredPlane(@sprites, "background", "Load/bg", Color.new(248, 248, 248), @viewport)
		y = 32
		commands.length.times do |i|
			@sprites["panel#{i}"] = PokemonLoadPanel.new(
				i, commands[i], (show_continue) ? (i == 0) : false, trainer, stats, map_id, @viewport
			)
			@sprites["panel#{i}"].x = (Graphics.width/2)-@sprites["panel#{i}"].width/2 
			@sprites["panel#{i}"].y = y
			@sprites["panel#{i}"].pbRefresh
			y += (show_continue && i == 0) ? 224 : 48
		end
		@sprites["cmdwindow"] = Window_CommandPokemon.new([])
		@sprites["cmdwindow"].viewport = @viewport
		@sprites["cmdwindow"].visible  = false
  end

	def pbSetParty(trainer)
		return if !trainer || !trainer.party
		meta = GameData::PlayerMetadata.get(trainer.character_ID)
		if meta
			filename = pbGetPlayerCharset(meta.walk_charset, trainer, true)
			@sprites["player"] = TrainerWalkingCharSprite.new(filename, @viewport)
			if !@sprites["player"].bitmap
				raise _INTL("Player character {1}'s walking charset was not found (filename: \"{2}\").", trainer.character_ID, filename)
			end
			charwidth  = @sprites["player"].bitmap.width # -> 128
			charheight = @sprites["player"].bitmap.height # -> 196
			panel0_x =  @sprites["panel0"].x # -> 52
			square_x = 81 # blue square width 
			@sprites["player"].x = panel0_x + square_x - (charwidth / 8) # 128 - (charwidth / 8) 
			@sprites["player"].y = 145 - (charheight / 8)
			@sprites["player"].z = 99999
		end
		# This draws the pokemon party but in Alola we don't have that
		#trainer.party.each_with_index do |pkmn, i|
		#@sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @viewport)
		#@sprites["party#{i}"].setOffset(PictureOrigin::CENTER)
		#@sprites["party#{i}"].x = 334 + (66 * (i % 2))
		#@sprites["party#{i}"].y = 112 + (50 * (i / 2))
		#@sprites["party#{i}"].z = 99999
    end
end