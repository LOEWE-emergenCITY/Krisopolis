func empty() -> void:
	pass

#extends GutTest
#
#func before_each() -> void:
	#OverworldStatesMngr.reset()
	#
	#gut.p("ran setup", 2)
#
#func after_each() -> void:
	#gut.p("ran teardown", 2)
#
#func before_all() -> void:
	#gut.p("Start OverWolrdStatesMngr Tests", 2)
#
#func after_all() -> void:	
	#gut.p("Finished OverWolrdStatesMngr Tests", 2)
#
#func _effective_state_tests(time: int = 4) -> void:
	#for i in range(time):
		#assert_eq(OverworldStatesMngr.get_effective_state_int("WaterState", i), 0)
		#
		#assert_true(OverworldStatesMngr.is_effective_state_eq("WaterState", "NONE", i), "WaterState %s eq NONE" % i)
		#assert_false(OverworldStatesMngr.is_effective_state_eq("WaterState", "CLEAN", i), "WaterState %s eq CLEAN" % i)
		#assert_false(OverworldStatesMngr.is_effective_state_eq("WaterState", "DIRTY", i), "WaterState %s eq DIRTY" % i)
		#
		#assert_true(OverworldStatesMngr.is_effective_state_neq("WaterState", "DIRTY", i), "WaterState %s neq DIRTY" % i)
		#assert_true(OverworldStatesMngr.is_effective_state_neq("WaterState", "CLEAN", i), "WaterState %s neq CLEAN" % i)
		#assert_false(OverworldStatesMngr.is_effective_state_neq("WaterState", "NONE", i), "WaterState %s neq NONE" % i)
#
#func test_facility_states_batched() -> void:
	#gut.p("Start Facility Test", 2)
	#
	##OverworldStatesMngr.set_crisis_difficulty(4, EMC_OverworldStatesMngr.Difficulty.EASY)
	#
	#var facility_effective_states: Dictionary = {
		#0: {
			#"ElectricityState": 1,
			#"WaterState": 2,
			#"MobileNetState": 1
		#}
	#}
	#var time: int = 5
	#
	#OverworldStatesMngr.begin_batch()
	#for i in range(time):
		#OverworldStatesMngr.add_state_layer_int("WaterState", "Test", 0, i)
	#
	#assert_eq_deep(OverworldStatesMngr.facility_effective_states, facility_effective_states)
	#OverworldStatesMngr.end_batch()
	#assert_ne_deep(OverworldStatesMngr.facility_effective_states, facility_effective_states)
	#
	#_effective_state_tests(time)
	#
	#OverworldStatesMngr.next_day(3)
	#
	#_effective_state_tests(time-3)
#
#func test_flags() -> void:
	#OverworldStatesMngr.add_flag_layer("NoEntry", "Market", 1)
	#
	#assert_false(OverworldStatesMngr.has_flag("NoEntry", "Market", 0))
	#assert_true(OverworldStatesMngr.has_flag("NoEntry", "Market", 1))
	#
	#OverworldStatesMngr.next_day(1)
	#
	#assert_true(OverworldStatesMngr.has_flag("NoEntry", "Market", 0))
	#assert_false(OverworldStatesMngr.has_flag("NoEntry", "Market", 1))
#
#func test_modifiers() -> void:
	#pass
