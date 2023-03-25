pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- sorting algorithms visualizer
-- insert line here

-- status
-- mostly done
-- -----------
-- bubble -> works as expected, needs extensive testing
-- insertion -> works as expected, needs extensive testing
-- selection -> works as expected, needs extensive testing
-- odd-even -> works as expected, needs extensive testing

-- to fix
-- -------
-- cocktail -> needs work
-- bogo -> needs work

-- to do
-- -----
-- merge ->  todo
-- quick -> todo
-- heap -> todo
-- radix -> todo

function _init()
	program_state = generate_program_state()
	sound = true
	colors = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
	
end


function _update60()
	program_state.frame += 1
	
	if program_state.mode == "title" then
		if (btnp(⬆️) or btnp(⬇️) or btnp(⬅️) or btnp(➡️) or btnp(🅾️) or btnp(❎)) program_state.mode = "select"
	elseif program_state.mode == "select" then
		if (btnp(⬅️)) then
			if (program_state.algorithm_selector == 1) then
				program_state.algorithm_selector = #program_state.algorithms_to_choose
			else
				program_state.algorithm_selector -= 1
			end
		elseif (btnp(➡️)) then
			if (program_state.algorithm_selector == #program_state.algorithms_to_choose) then
				program_state.algorithm_selector = 1
			else
				program_state.algorithm_selector += 1
			end
		elseif (btnp(❎)) then
			program_state.mode = "count_select"
		elseif(btnp(🅾️)) then
			program_state.mode = "title"
			program_state.algorithm_selector = 1
		end
	elseif program_state.mode == "count_select" then
		if (btnp(⬅️)) then
			if (program_state.count_selector == 1) then
				program_state.count_selector = #program_state.item_count_to_choose
			else
				program_state.count_selector -= 1
			end
		elseif (btnp(➡️)) then
			if (program_state.count_selector == #program_state.item_count_to_choose) then
				program_state.count_selector = 1
			else
				program_state.count_selector += 1
			end
		elseif (btnp(❎)) then
			program_state.mode = "algorithm"
			program_state.algorithm_state = generate_algorithm_state(program_state.algorithms_to_choose[program_state.algorithm_selector], program_state.item_count_to_choose[program_state.count_selector])
			program_state.bars = generate_bars(program_state.item_count_to_choose[program_state.count_selector])
			program_state.bars = randomize_bars(program_state) 
		elseif (btnp(🅾️)) then
			program_state.mode = "select"
			program_state.count_selector = 1
		end
	else
		if(btnp(❎)) then
			program_state.bars = nil
			program_state.algorithm_state = nil
			program_state.primary_sfx_to_play=0
			program_state.secondary_sfx_to_play=0
			program_state.third_sfx_to_play=0
			program_state.algorithm_selector=1
			program_state.count_selector = 1
			program_state.mode = "select"						
			return
		end
	
		if(btnp(🅾️))  sound = not sound
	
		
		program_state.algorithm_state.has_ended = program_state.algorithm_state.sort_done and program_state.algorithm_state.starting_position == program_state.algorithm_state.item_count
		update_bars(program_state)
		local sfx = get_sfx(program_state)
		program_state.primary_sfx_to_play = sfx[1]
		program_state.secondary_sfx_to_play = sfx[2]
		program_state.third_sfx_to_play = sfx[3]
	end
end

function _draw()
 cls()
 
 if program_state.mode == "title" then
 	print("sorting algorithms in pico8", 11, 63, 137)
 	print("press any button to continue", 11, 71, 137)
 elseif program_state.mode == "select" then
 	spr(1, 22, 63)
 	spr(1, 60, 63, 1, 1, true)
 	print(program_state.algorithms_to_choose[program_state.algorithm_selector], 30, 63, 137)
 	print("change options with d-pad", 30, 71, 137)
 	print("select with 🅾️ or ❎", 30, 79, 137)
 elseif program_state.mode == "count_select" then
 	spr(1, 22, 63)
 	spr(1, 60, 63, 1, 1, true)
 	print(program_state.item_count_to_choose[program_state.count_selector], 30, 63, 137)
 	print("change options with d-pad", 30, 71, 137)
 	print("select with 🅾️ or ❎", 30, 79, 137)
 else
 	draw_bars(program_state)
 	print(program_state.frame, 137)
 	print(program_state.primary_sfx_to_play, 137)
 	print(program_state.secondary_sfx_to_play, 137)
 	print(program_state.third_sfx_to_play, 137)
-- 	print(verify_bars(program_state.bars), 137)
-- 	print(program_state.algorithm_state.starting_position, 137)
 	print(program_state.algorithm_state.starting_position, 137)
 	print(program_state.algorithm_state.compare_position, 137)
 	print(program_state.algorithm_state.odd_even_sorted, 137)
	print("press ❎ to go back", 20, 0, 137)
	print("press 🅾️ to toggle sound", 20, 8, 137)
		
	
 end
 
end

function draw_bars_done(program_state)
	local scale = program_state.algorithm_state.scale
	for i=0, program_state.algorithm_state.item_count - 1, 1 do
		if ((i+1) == program_state.algorithm_state.starting_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 8)
		elseif ((i+1) < program_state.algorithm_state.starting_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 11)
		else 
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 7)
		end
	end
end

function draw_bars_bubble(program_state)
	local scale = program_state.algorithm_state.scale
	for i=0, program_state.algorithm_state.item_count-1, 1 do
		if ((i+1) == program_state.algorithm_state.starting_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 136)
		else
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 7)
		end
	end	
end

function draw_bars_selection(program_state)
	local scale = program_state.algorithm_state.scale
	for i=0, program_state.algorithm_state.item_count-1, 1 do
		if ((i+1) == program_state.algorithm_state.starting_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 136)
		elseif ((i+1) == program_state.algorithm_state.selection_secondary_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 139)
		elseif ((i+1) == program_state.algorithm_state.selection_index) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 134)
		else
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 7)
		end
	end	
end

function draw_bars_insertion(program_state)
	local scale = program_state.algorithm_state.scale
	for i=0, program_state.algorithm_state.item_count-1, 1 do
		if ((i+1) == program_state.algorithm_state.compare_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 136)
		elseif ((i+1) == program_state.algorithm_state.starting_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 139)
		else
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 7)
		end
	end
end

function draw_bars_odd_even(program_state)
	local scale = program_state.algorithm_state.scale
	for i=0, program_state.algorithm_state.item_count-1, 1 do
		if ((i+1) == program_state.algorithm_state.compare_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 136)
		elseif ((i+1) == program_state.algorithm_state.starting_position) then
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 139)
		else
			rectfill((i * scale), 127, (i * scale) + (scale - 1), (127 - (program_state.bars[i+1]-1)*scale), 7)
		end
	end
end	

function draw_bars(program_state)
	if (program_state.algorithm_state.sort_done) then
		draw_bars_done(program_state)
	else	
		if (program_state.algorithm_state.algorithm=="bubble") draw_bars_bubble(program_state)
		if (program_state.algorithm_state.algorithm=="selection") draw_bars_selection(program_state)
		if (program_state.algorithm_state.algorithm=="insertion") draw_bars_insertion(program_state)
		if (program_state.algorithm_state.algorithm=="odd-even") draw_bars_odd_even(program_state)	
	end
end

function update_bars(program_state)
	if (program_state.algorithm_state.sort_done) then
		if (program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count) program_state.algorithm_state.starting_position += 1
	else
		if (program_state.algorithm_state.algorithm == "bubble") bubble_sort_step(program_state)
		if (program_state.algorithm_state.algorithm == "cocktail") cocktail_sort_step(program_state)
		if (program_state.algorithm_state.algorithm == "bogo") bogo_sort_step(program_state)
		if (program_state.algorithm_state.algorithm == "selection") selection_sort_step(program_state)
		if (program_state.algorithm_state.algorithm == "insertion") insertion_sort_step(program_state)
		if (program_state.algorithm_state.algorithm == "odd-even") odd_even_sort_step(program_state)
	end
	if (sound and not program_state.algorithm_state.has_ended) then
		play_sfx(program_state)
	end
end

function generate_program_state()
	return {
									mode="title",
									bars=nil,
									frame=0,
									primary_sfx_to_play=0,
									secondary_sfx_to_play=0,
									third_sfx_to_play=0,
									algorithm_selector=1,
									algorithms_to_choose = {"bubble", "cocktail", "bogo", "selection", "insertion", "odd-even"},
									item_count_to_choose = {2, 4, 8, 16, 32, 64, 128},
									count_selector=1,
									algorithm_state=nil
								}
end

function generate_algorithm_state(algorithm, item_count)
	return {
									swaps=0,
									compares=0,
									array_accesses=0,
									has_begun=false,
									has_changed=false,
									algorithm=algorithm,
									item_count=item_count,
									passed_through_array=true,
									starting_position=1,
									has_ended=false,
									swapped=false,
									sort_done=false,
									forward=true,
									array_start=0,
									array_end=item_count - 1,
									passed_through_forward=false,
									started_backwards=false,
									check_step=true,
									compare_position=nil,
									selection_index=nil,
									insertion_key=nil,
									temp_highest_value=1,
									bubble_elements_to_examine=item_count,
									scale=128/item_count,
									odd_even_sorted=false,
									odd_even_temp=0,
									odd_even_first_pass=true,
									compare_position_for_sound=1,
									selection_secondary_position=nil,
									odd_even_beginning_second_pass=false
								}
end

function play_sfx(program_state)
	if (not program_state.algorithm_state.sort_done) then 
		if (program_state.algorithm_state.algorithm == "selection") sfx(program_state.third_sfx_to_play, 3)
		sfx(program_state.secondary_sfx_to_play, 2)
	end
	sfx(program_state.primary_sfx_to_play, 1)
	
end

function get_sfx(program_state)
	local scale = program_state.algorithm_state.scale
	return_val = {}
	--if (program_state.algorithm_state.algorithm == "bogo" and not program_state.algorithm_state.check_step) return flr(rnd(63))
	--if (program_state.algorithm_state.algorithm == "selection") then
	--	return flr(((program_state.bars[program_state.algorithm_state.selection_index] - 1) * scale) / 2)
	--end
	if (program_state.algorithm_state.sort_done) then
		return_val[1] =  flr(((program_state.bars[program_state.algorithm_state.starting_position] - 1) * scale) / 2)
		
	else
		if (program_state.algorithm_state.algorithm == "bubble") then
			return_val[1] = flr(((program_state.algorithm_state.temp_highest_value - 1) * scale) / 2)
			return_val[2] = flr(((program_state.bars[program_state.algorithm_state.starting_position] - 1) * scale) / 2)
		elseif (program_state.algorithm_state.algorithm == "selection") then
			return_val[1] = flr(((program_state.bars[program_state.algorithm_state.selection_secondary_position] - 1) * scale) / 2)
			return_val[2] = flr(((program_state.bars[program_state.algorithm_state.starting_position] - 1) * scale) / 2)
			return_val[3] = flr(((program_state.bars[program_state.algorithm_state.selection_index] - 1) * scale) / 2)
		elseif (program_state.algorithm_state.algorithm == "insertion") then
			return_val[1] = flr(((program_state.bars[program_state.algorithm_state.compare_position_for_sound]) * scale) / 2)
			return_val[2] = flr(((program_state.bars[program_state.algorithm_state.starting_position] - 1) * scale) / 2)
		elseif (program_state.algorithm_state.algorithm == "odd-even") then
			return_val[1] = flr(((program_state.bars[program_state.algorithm_state.compare_position]) * scale) / 2)
			return_val[2] = flr(((program_state.bars[program_state.algorithm_state.starting_position] - 1) * scale) / 2)
		else
			return_val[1] = flr(((program_state.bars[program_state.algorithm_state.starting_position] - 1) * scale) / 2)
		end
	end	

	return return_val

end

function verify_bars(bars)
	for i=1, #bars, 1 do
		if bars[i] == nil then
			return i
		end
	end
	return -1
end

function generate_bars(num_bars)
	return_val = {}
	for i=1, num_bars, 1 do
		return_val[i] = i
	end
	return return_val
end

function randomize_bars(program_state)
	for i = #program_state.bars, 2, -1 do
		local j = 1 + flr(rnd(i))
		program_state.bars[i], program_state.bars[j] = program_state.bars[j], program_state.bars[i]
		if (program_state.algorithm_state.algorithm == "bogo" and program_state.algorithm_state.has_begun) program_state.algorithm_state.array_accesses += 2 
	end
	return program_state.bars
end

function is_sorted_step(program_state)
	local i = program_state.algorithm_state.starting_position
	if program_state.bars[i] > program_state.bars[i+1] then
		program_state.algorithm_state.compares += 1
		program_state.algorithm_state.array_accesses += 2
		program_state.algorithm_state.check_step = false
	end
	program_state.algorithm_state.starting_position += 1
end 

function selection_sort_step(program_state)
	if not program_state.algorithm_state.has_begun then
		program_state.algorithm_state.has_begun = true
		program_state.algorithm_state.starting_position = 1
	end
	if program_state.algorithm_state.starting_position <= program_state.algorithm_state.item_count - 1 then
		if program_state.algorithm_state.passed_through_array then
			program_state.algorithm_state.selection_index = program_state.algorithm_state.starting_position
			program_state.algorithm_state.selection_secondary_position = program_state.algorithm_state.selection_index + 1
			program_state.algorithm_state.passed_through_array = false
		else
			if program_state.algorithm_state.selection_secondary_position < program_state.algorithm_state.item_count then
				local is_bigger = program_state.bars[program_state.algorithm_state.selection_secondary_position] < program_state.bars[program_state.algorithm_state.selection_index]
				if is_bigger then
					program_state.algorithm_state.selection_index = program_state.algorithm_state.selection_secondary_position
				end
				program_state.algorithm_state.selection_secondary_position += 1
			else
				local is_bigger = program_state.bars[program_state.algorithm_state.selection_secondary_position] < program_state.bars[program_state.algorithm_state.selection_index]
				if is_bigger then
					program_state.algorithm_state.selection_index = program_state.algorithm_state.selection_secondary_position
				end
				program_state.bars[program_state.algorithm_state.starting_position], program_state.bars[program_state.algorithm_state.selection_index] = program_state.bars[program_state.algorithm_state.selection_index], program_state.bars[program_state.algorithm_state.starting_position]
				program_state.algorithm_state.starting_position += 1
				program_state.algorithm_state.passed_through_array = true
			end
		end
	else
		program_state.algorithm_state.sort_done = true
		program_state.algorithm_state.starting_position = 1
	end

end

function insertion_sort_step(program_state)
	if not program_state.algorithm_state.has_begun then
		program_state.algorithm_state.has_begun = true
		program_state.algorithm_state.starting_position = 2
	end
	for i = program_state.algorithm_state.starting_position, program_state.algorithm_state.item_count do
		program_state.algorithm_state.starting_position = i
		if (program_state.algorithm_state.insertion_key == nil) program_state.algorithm_state.insertion_key = program_state.bars[i]
		if (program_state.algorithm_state.compare_position == nil) then
			program_state.algorithm_state.compare_position = i - 1
			program_state.algorithm_state.compare_position_for_sound = i
		end
		if program_state.algorithm_state.compare_position > 0 and program_state.bars[program_state.algorithm_state.compare_position] > program_state.algorithm_state.insertion_key then
			program_state.bars[program_state.algorithm_state.compare_position + 1] = program_state.bars[program_state.algorithm_state.compare_position]
			program_state.algorithm_state.compare_position -= 1
			if (program_state.algorithm_state.compare_position_for_sound > 1) program_state.algorithm_state.compare_position_for_sound -= 1
			break
		else
			program_state.bars[program_state.algorithm_state.compare_position + 1] = program_state.algorithm_state.insertion_key
			program_state.algorithm_state.compare_position = nil	
			program_state.algorithm_state.compare_position_for_sound=1
			program_state.algorithm_state.insertion_key = nil
			program_state.algorithm_state.starting_position += 1
			break
		end
	end
	if program_state.algorithm_state.starting_position > program_state.algorithm_state.item_count then
		program_state.algorithm_state.sort_done = true
		program_state.algorithm_state.starting_position = 1
	end
end

function bogo_sort_step(program_state)
	if program_state.algorithm_state.check_step then
		is_sorted_step(program_state)
	else
		randomize_bars(program_state)
	end
end

function bubble_sort_step(program_state)
	if ((not program_state.algorithm_state.has_begun) or (program_state.algorithm_state.has_begun and program_state.algorithm_state.has_changed)) then
		if (not program_state.algorithm_state.has_begun) program_state.algorithm_state.has_begun=true
		if program_state.algorithm_state.passed_through_array then
			program_state.algorithm_state.bubble_elements_to_examine -= 1
			program_state.algorithm_state.passed_through_array = false
			program_state.algorithm_state.has_changed = false
			program_state.algorithm_state.temp_highest_value = program_state.bars[1]
		end
		local counter
		
		for i=program_state.algorithm_state.starting_position, program_state.algorithm_state.bubble_elements_to_examine  do
			counter = i
			local left_bigger_than_right = program_state.bars[i] > program_state.bars[i+1]
			program_state.algorithm_state.compares += 1 
			if left_bigger_than_right then
				program_state.algorithm_state.temp_highest_value = program_state.bars[i]
				program_state.bars[i], program_state.bars[i+1] = program_state.bars[i+1], program_state.bars[i]
				program_state.algorithm_state.swaps += 1
				program_state.algorithm_state.has_changed = true
				program_state.algorithm_state.starting_position = i
				break
			end
		end
		if (counter >= program_state.algorithm_state.bubble_elements_to_examine) then
			program_state.algorithm_state.starting_position=1
			program_state.algorithm_state.passed_through_array=true	
		end
	end
	if program_state.algorithm_state.has_begun and not(program_state.algorithm_state.has_changed) then
		program_state.algorithm_state.sort_done = true
	end
end

function cocktail_sort_step(program_state)	
	if ((not program_state.algorithm_state.has_begun) or (program_state.algorithm_state.has_begun and program_state.algorithm_state.swapped)) then
		if (not program_state.algorithm_state.has_begun) program_state.algorithm_state.has_begun=true
		
		if program_state.algorithm_state.passed_through_array then
			program_state.algorithm_state.passed_through_array = false
			program_state.algorithm_state.swapped = false
			program_state.algorithm_state.passed_through_forward=false
			program_state.algorithm_state.array_start += 1
			program_state.algorithm_state.starting_position = program_state.algorithm_state.array_start 
		end
		
		if (program_state.algorithm_state.forward) then
			for i=program_state.algorithm_state.starting_position, program_state.algorithm_state.array_end do
				local left_bigger_than_right = program_state.bars[i] > program_state.bars[i+1]
				program_state.algorithm_state.compares += 1 
				if left_bigger_than_right then
					program_state.bars[i], program_state.bars[i+1] = program_state.bars[i+1], program_state.bars[i]
					program_state.algorithm_state.swaps += 1
					program_state.algorithm_state.starting_position = i
					program_state.algorithm_state.swapped = true
					return
				end
			end
			program_state.algorithm_state.forward = false
			program_state.algorithm_state.starting_position = program_state.algorithm_state.array_end
			program_state.algorithm_state.passed_through_forward = true
		end
		
		if (program_state.algorithm_state.passed_through_forward and not program_state.algorithm_state.started_backwards) then
			program_state.algorithm_state.array_end -= 1
		end
		
		if ((program_state.algorithm_state.swapped and not program_state.algorithm_state.forward) or (not program_state.algorithm_state.started_backwards and not program_state.algorithm_state.swapped and not program_state.algorithm_state.forward)) then
			program_state.algorithm_state.started_backwards = true
			for i=program_state.algorithm_state.starting_position, program_state.algorithm_state.array_start, -1 do
				local right_bigger_than_left = program_state.bars[i] < program_state.bars[i+1]
				program_state.algorithm_state.compares += 1
				if right_bigger_than_left then
					program_state.bars[i], program_state.bars[i+1] = program_state.bars[i+1], program_state.bars[i]
					program_state.algorithm_state.swaps += 1
					program_state.algorithm_state.starting_position = i
					program_state.algorithm_state.swapped = true
					return
				end
			end
			program_state.algorithm_state.forward=true
			program_state.algorithm_state.passed_through_array=true	
			program_state.algorithm_state.started_backwards = false
		end
	end
end	

function odd_even_sort_step(program_state)
	if (not program_state.algorithm_state.has_begun) program_state.algorithm_state.has_begun=true
	if program_state.algorithm_state.passed_through_array then
		if program_state.algorithm_state.odd_even_sorted then
			program_state.algorithm_state.sort_done = true
			program_state.algorithm_state.starting_position=1
			return
		else
			program_state.algorithm_state.odd_even_sorted=true
			program_state.algorithm_state.odd_even_temp=0
			program_state.algorithm_state.odd_even_first_pass=true
			program_state.algorithm_state.passed_through_array=false
			program_state.algorithm_state.starting_position=2
		end
	end
	if program_state.algorithm_state.odd_even_first_pass then
		if program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count - 2 then
			program_state.algorithm_state.compare_position = program_state.algorithm_state.starting_position + 1
			if program_state.bars[program_state.algorithm_state.starting_position] > program_state.bars[program_state.algorithm_state.starting_position + 1] then
				program_state.algorithm_state.odd_even_temp = program_state.bars[program_state.algorithm_state.starting_position]
				program_state.bars[program_state.algorithm_state.starting_position] = program_state.bars[program_state.algorithm_state.starting_position+1]
				program_state.bars[program_state.algorithm_state.starting_position+1] = program_state.algorithm_state.odd_even_temp
				program_state.algorithm_state.odd_even_sorted = false
				if (program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count - 2) program_state.algorithm_state.starting_position += 2
				return
			else
				if (program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count - 2) program_state.algorithm_state.starting_position += 2
				return
			end
		else
			program_state.algorithm_state.compare_position = program_state.algorithm_state.starting_position + 1
			if program_state.bars[program_state.algorithm_state.starting_position] > program_state.bars[program_state.algorithm_state.starting_position + 1] then
				program_state.algorithm_state.odd_even_temp = program_state.bars[program_state.algorithm_state.starting_position]
				program_state.bars[program_state.algorithm_state.starting_position] = program_state.bars[program_state.algorithm_state.starting_position+1]
				program_state.bars[program_state.algorithm_state.starting_position+1] = program_state.algorithm_state.odd_even_temp
				program_state.algorithm_state.odd_even_sorted = false
			end
			program_state.algorithm_state.odd_even_first_pass=false
			program_state.algorithm_state.odd_even_beginning_second_pass=true
			return
		end
	else
		if program_state.algorithm_state.odd_even_beginning_second_pass then
			program_state.algorithm_state.starting_position = 1
			program_state.algorithm_state.odd_even_beginning_second_pass = false
		end
		if program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count - 2 then
			program_state.algorithm_state.compare_position = program_state.algorithm_state.starting_position + 1
			if program_state.bars[program_state.algorithm_state.starting_position] > program_state.bars[program_state.algorithm_state.starting_position + 1] then
				program_state.algorithm_state.odd_even_temp = program_state.bars[program_state.algorithm_state.starting_position]
				program_state.bars[program_state.algorithm_state.starting_position] = program_state.bars[program_state.algorithm_state.starting_position+1]
				program_state.bars[program_state.algorithm_state.starting_position+1] = program_state.algorithm_state.odd_even_temp
				program_state.algorithm_state.odd_even_sorted = false
				if (program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count - 2) program_state.algorithm_state.starting_position += 2
				return
			else
				if (program_state.algorithm_state.starting_position < program_state.algorithm_state.item_count - 2) program_state.algorithm_state.starting_position += 2
				return
			end
		else
			program_state.algorithm_state.compare_position = program_state.algorithm_state.starting_position + 1
			if program_state.bars[program_state.algorithm_state.starting_position] > program_state.bars[program_state.algorithm_state.starting_position + 1] then
				program_state.algorithm_state.odd_even_temp = program_state.bars[program_state.algorithm_state.starting_position]
				program_state.bars[program_state.algorithm_state.starting_position] = program_state.bars[program_state.algorithm_state.starting_position+1]
				program_state.bars[program_state.algorithm_state.starting_position+1] = program_state.algorithm_state.odd_even_temp
				program_state.algorithm_state.odd_even_sorted = false
			end
			program_state.algorithm_state.passed_through_array=true
			return
		end
	end
end
__gfx__
00000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000099009909990999099909900099000009990900009900990999099909990909099900990000099909900000099909990099009909990000000000
00000000000900090909090090009009090900000009090900090009090909009000900909099909000000009009090000090900900900090909090000000000
00000000000999090909900090009009090900000009990900090009090990009000900999090909990000009009090000099900900900090909990000000000
00000000000009090909090090009009090909000009090900090909090909009000900909090900090000009009090000090000900900090909090000000000
00000000000990099009090090099909090999000009090999099909900909099900900909090909900000099909090000090009990099099009990000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000999099909990099009900000999099009090000099909090999099900990990000009990099000000990099099009990999099009090999000000
00000000000909090909000900090000000909090909090000090909090090009009090909000000900909000009000909090900900090090909090900000000
00000000000999099009900999099900000999090909990000099009090090009009090909000000900909000009000909090900900090090909090990000000
00000000000900090909000009000900000909090900090000090909090090009009090909000000900909000009000909090900900090090909090900000000
00000000000900090909990990099000000909090909990000099900990090009009900909000000900990000000990990090900900999090900990999000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000100000005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
000100000175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750
000100000275002750027500275002750027500275002750027500275002750027500275002750027500275002750027500275002750027500275002750027500275002750027500275002750027500275002750
000100000375003750037500375003750037500375003750037500375003750037500375003750037500375003750037500375003750037500375003750037500375003750037500375003750037500375003750
000100000475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750047500475004750
000100000575005750057500575005750057500575005750057500575005750057500575005750057500575005750057500575005750057500575005750057500575005750057500575005750057500575005750
000100000675006750067500675006750067500675006750067500675006750067500675006750067500675006750067500675006750067500675006750067500675006750067500675006750067500675006750
000100000775007750077500775007750077500775007750077500775007750077500775007750077500775007750077500775007750077500775007750077500775007750077500775007750077500775007750
000100000875008750087500875008750087500875008750087500875008750087500875008750087500875008750087500875008750087500875008750087500875008750087500875008750087500875008750
000100000975009750097500975009750097500975009750097500975009750097500975009750097500975009750097500975009750097500975009750097500975009750097500975009750097500975009750
000100000a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a7500a750
000100000b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b7500b750
000100000c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c7500c750
000100000d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d7500d750
000100000e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e7500e750
000100000f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f750
000100001075010750107501075010750107501075010750107501075010750107501075010750107501075010750107501075010750107501075010750107501075010750107501075010750107501075010750
000100001175011750117501175011750117501175011750117501175011750117501175011750117501175011750117501175011750117501175011750117501175011750117501175011750117501175011750
000100001275012750127501275012750127501275012750127501275012750127501275012750127501275012750127501275012750127501275012750127501275012750127501275012750127501275012750
000100001375013750137501375013750137501375013750137501375013750137501375013750137501375013750137501375013750137501375013750137501375013750137501375013750137501375013750
000100001475014750147501475014750147501475014750147501475014750147501475014750147501475014750147501475014750147501475014750147501475014750147501475014750147501475014750
000100001575015750157501575015750157501575015750157501575015750157501575015750157501575015750157501575015750157501575015750157501575015750157501575015750157501575015750
000100001675016750167501675016750167501675016750167501675016750167501675016750167501675016750167501675016750167501675016750167501675016750167501675016750167501675016750
000100001775017750177501775017750177501775017750177501775017750177501775017750177501775017750177501775017750177501775017750177501775017750177501775017750177501775017750
000100001875018750187501875018750187501875018750187501875018750187501875018750187501875018750187501875018750187501875018750187501875018750187501875018750187501875018750
000100001975019750197501975019750197501975019750197501975019750197501975019750197501975019750197501975019750197501975019750197501975019750197501975019750197501975019750
000100001a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a7501a750
000100001b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b7501b750
000100001c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c7501c750
000100001d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d7501d750
000100001e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e7501e750
000100001f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f750
000100002075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750
000100002175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750
000100002275022750227502275022750227502275022750227502275022750227502275022750227502275022750227502275022750227502275022750227502275022750227502275022750227502275022750
000100002375023750237502375023750237502375023750237502375023750237502375023750237502375023750237502375023750237502375023750237502375023750237502375023750237502375023750
000100002475024750247502475024750247502475024750247502475024750247502475024750247502475024750247502475024750247502475024750247502475024750247502475024750247502475024750
000100002575025750257502575025750257502575025750257502575025750257502575025750257502575025750257502575025750257502575025750257502575025750257502575025750257502575025750
000100002675026750267502675026750267502675026750267502675026750267502675026750267502675026750267502675026750267502675026750267502675026750267502675026750267502675026750
000100002775027750277502775027750277502775027750277502775027750277502775027750277502775027750277502775027750277502775027750277502775027750277502775027750277502775027750
000100002875028750287502875028750287502875028750287502875028750287502875028750287502875028750287502875028750287502875028750287502875028750287502875028750287502875028750
000100002975029750297502975029750297502975029750297502975029750297502975029750297502975029750297502975029750297502975029750297502975029750297502975029750297502975029750
000100002a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a7502a750
000100002b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b750
000100002c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c7502c750
000100002d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d750
000100002e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e7502e750
000100002f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f7502f750
000100003075030750307503075030750307503075030750307503075030750307503075030750307503075030750307503075030750307503075030750307503075030750307503075030750307503075030750
000100003175031750317503175031750317503175031750317503175031750317503175031750317503175031750317503175031750317503175031750317503175031750317503175031750317503175031750
000100003275032750327503275032750327503275032750327503275032750327503275032750327503275032750327503275032750327503275032750327503275032750327503275032750327503275032750
000100003375033750337503375033750337503375033750337503375033750337503375033750337503375033750337503375033750337503375033750337503375033750337503375033750337503375033750
000100003475034750347503475034750347503475034750347503475034750347503475034750347503475034750347503475034750347503475034750347503475034750347503475034750347503475034750
000100003575035750357503575035750357503575035750357503575035750357503575035750357503575035750357503575035750357503575035750357503575035750357503575035750357503575035750
000100003675036750367503675036750367503675036750367503675036750367503675036750367503675036750367503675036750367503675036750367503675036750367503675036750367503675036750
000100003775037750377503775037750377503775037750377503775037750377503775037750377503775037750377503775037750377503775037750377503775037750377503775037750377503775037750
000100003873038730387303873038730387303873038730387303873038730387303873038730387303873038730387303873038730387303873038730387303873038730387303873038730387303873038730
000100003973039730397303973039730397303973039730397303973039730397303973039730397303973039730397303973039730397303973039730397303973039730397303973039730397303973039730
000100003a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a7303a730
000100003b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b7303b730
000100003c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c7303c730
000100003d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d7303d730
000100003e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e7303e730
000100003f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f7303f730
__music__
00 45424344

