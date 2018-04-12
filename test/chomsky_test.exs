defmodule ChomskyTest do
	use ExUnit.Case

	test "apply_empty_relations1" do
		relation = {'A', ['B','C']}
		assert Chomsky.apply_empty_relations(relation, 'A') == [{'A', ['B','C']}]
	end

	test "apply_empty_relations2" do
		relation = {'A', ['B','C']}
		assert Enum.sort(Chomsky.apply_empty_relations(relation, 'B')) == Enum.sort([{'A', ['C']}, {'A', ['B','C']}])
	end

	test "apply_empty_relations3" do
		relation = {'A', ['B']}
		assert Enum.sort(Chomsky.apply_empty_relations(relation, 'B')) == Enum.sort([{'A', []}, {'A', ['B']}])
	end

	test "apply_empty_relations4" do
		relation = {'A', ['B','C','B','C']}
		assert Enum.sort(Chomsky.apply_empty_relations(relation, 'B')) == Enum.sort([{'A', ['B','C','B','C']}, 
																					 {'A', ['C','B','C']}, 
																					 {'A', ['B','C','C']},
																					 {'A', ['C','C']}])
	end

	test "apply_empty_relations5" do
		relation = {'A', ['B','B']}
		assert Enum.sort(Chomsky.getDistincts(Chomsky.apply_empty_relations(relation, 'B'))) == Enum.sort([{'A', ['B','B']}, 
																					 					   {'A', ['B']},
																					    				   {'A', []}])
	end

	test "get_new_relations1" do
		old_relations = [{'A', ['B','C','B','C']}, {'A', ['B','B']}]
		char = 'B'
		assert Chomsky.get_new_relations(old_relations,char) |> Enum.sort() == Enum.sort([{'A', ['B','C','B','C']}, 
																					 	  {'A', ['C','B','C']}, 
																					 	  {'A', ['B','C','C']},
																					 	  {'A', ['C','C']},
																					 	  {'A', ['B','B']}, 
																					 	  {'A', ['B']},
																					      {'A', []}])
	end

	test "derivate_empty_relations1" do
		old_relations = [{'S',['A']}, {'A', ['a','B']}, {'B',['A']}, {'B',['b']}, {'A',['B']}]
		empty_chars = ['A']
		assert Chomsky.derivate_empty_relations(old_relations, empty_chars) |> Enum.sort() == Enum.sort([{'S',['A']}, 
																									   {'S',[]}, 
																									   {'A', ['a','B']}, 
																									   {'B',['A']}, 
																									   {'B',[]}, 
																									   {'B',['b']},
																									   {'A',['B']}])
	end

	test "derivate_empty_relations2" do
		old_relations = [{'S',['A']}, 
				     	 {'A', ['a','B']}, 
				     	 {'B',['A']},
				     	 {'B',['b']},
				     	 {'A',['B']}]
		empty_chars = ['B','S']
    	assert Chomsky.derivate_empty_relations(old_relations, empty_chars) |> Enum.sort() == Enum.sort([{'S',['A']}, 
    																								 	 {'A', ['a','B']}, 
    																								 	 {'A', ['a']}, 
    																								 	 {'B',['A']}, 
    																								 	 {'B',['b']},
    																								 	 {'A', []},
    																								 	 {'A', ['B']}])
	end

	test "derivate_empty_relations3" do
		old_relations = [{'S',['A']}, 
				     	 {'A', ['a','B']}, 
				     	 {'B',['A']},
				     	 {'B',['b']},
				     	 {'A',['B']}]
		empty_chars = ['A','B','S']
    	assert Chomsky.derivate_empty_relations(old_relations, empty_chars) |> Enum.sort() == Enum.sort([{'S',['A']}, 
    																									 {'S',[]},
    																								 	 {'A', ['a','B']}, 
    																								 	 {'A', ['a']}, 
    																								 	 {'B',['A']},
    																								 	 {'B', []}, 
    																								 	 {'B',['b']},
    																								 	 {'A', ['B']},
    																								 	 {'A', []}])
	end


	test "get_empty_rules1" do
		old_relations = [{'S', ['A']}, {'A', ['a','B']}, {'A',[]} ]
		{no_empty_relations, empty_rule_lhs} = Chomsky.get_empty_rules(old_relations)
			assert {Enum.sort(no_empty_relations), Enum.sort(empty_rule_lhs)} == {Enum.sort([{'S', ['A']},
																							{'A',  ['a','B']}]), 
																				  Enum.sort(['A','S'])}
	end

	test "get_empty_rules2" do
		old_relations = [{'S',['A']}, {'A', ['a','B']}, {'B',['A']}, {'B',['b']}, {'A',['B']}, {'A',[]}]
		{no_empty_relations, empty_rule_lhs} = Chomsky.get_empty_rules(old_relations)
		assert {Enum.sort(no_empty_relations), Enum.sort(empty_rule_lhs)} == {Enum.sort([{'S', ['A']}, 
    																			    	 {'A', ['a','B']},
    																					 {'B', ['A']}, 
    																					 {'B', ['b']},
    																					 {'A', ['B']}]),
																			  Enum.sort(['A','B','S'])}
			
	end	

	test "get_empty_rules3" do
		old_relations = [{'S',['A']}, {'A', ['a','B']}, {'B',['A','S']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		{no_empty_relations, empty_rule_lhs} = Chomsky.get_empty_rules(old_relations)
		assert {Enum.sort(no_empty_relations), Enum.sort(empty_rule_lhs)} == {Enum.sort([{'S', ['A']}, 
    																			    	 {'A', ['a','B']},
    																					 {'B', ['A','S']},
    																					 {'B', ['b']},
    																					 {'B', ['a','b']},
    																					 {'A', ['B']}]),
																			  Enum.sort(['A','B','S'])}

	end

	test "remove_empty_relations1" do
		old_non_terminals = ['S','A','B']
		old_terminals = ['a','b']
		start = 'S'
		old_relations = [{'S',['A']}, {'A', ['a','B']}, {'B',['A','S']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		old_grammar = [old_non_terminals, old_terminals, start, old_relations]
		[_, _, _, new_relations] = Chomsky.remove_empty_relations(old_grammar)
		assert Enum.sort(new_relations) == Enum.sort([{'S', ['A']}, 
    												  {'A', ['a','B']},
    												  {'A', ['a']},
    												  {'B', ['A']},
    												  {'B', ['S']},
    									  			  {'B', ['A','S']},
    									  			  {'B', ['b']},
    									  			  {'B', ['a','b']},
    									  			  {'A', ['B']}])

	end

	test "remove_empty_relations2" do
		old_non_terminals = ['S','A','B']
		old_terminals = ['a','b']
		start = 'S'
		old_relations = [{'S',['A']}, {'A', ['a','B']}, {'B',['A','S','B']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		old_grammar = [old_non_terminals, old_terminals, start, old_relations]
		[_, _, _, new_relations] = Chomsky.remove_empty_relations(old_grammar)
		assert Enum.sort(new_relations) == Enum.sort([{'S', ['A']}, 
    												  {'A', ['a','B']},
    												  {'A', ['a']},
    												  {'B', ['A']},
    												  {'B', ['S']},
    												  {'B', ['B']},
    												  {'B', ['A','B']},
    									  			  {'B', ['A','S']},
    									  			  {'B', ['S','B']},
    									  			  {'B',['A','S','B']},
    									  			  {'B', ['b']},
    									  			  {'B', ['a','b']},
    									  			  {'A', ['B']}])

	end

	test "derivate_unit_realations1" do
		unit_relation = {'S', ['A']}
		old_relations = [{'A', ['a','B']}, {'B',['A','S','B']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		seen = []
		assert Enum.sort(Chomsky.derivate_unit_relations(unit_relation, old_relations, seen)) == Enum.sort([{'S', ['a','B']},
																									 		{'S', ['B']},
																									 		{'S', []}])
	end

	test "derivate_unit_realations2" do
		unit_relation = {'S', ['A']}
		old_relations = [{'A', ['a','B']}, {'B',['A','S','B']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		seen = [{'S', ['a','B']}]
		assert Enum.sort(Chomsky.derivate_unit_relations(unit_relation, old_relations, seen)) == Enum.sort([{'S', ['B']},
																									 		{'S', []}])
	end

	test "derivate_unit_relations3" do
		unit_relation = {'S', ['A']}
		old_relations = [{'A', ['a','B']}, {'B',['A','S','B']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		seen = []
		assert Enum.sort(Chomsky.derivate_unit_relations(unit_relation, old_relations, seen)) == Enum.sort([{'S', ['a','B']},
																									 		{'S', ['B']},
																									 		{'S', []}])
		
	end

	test "remove_unit_relations1" do
		old_non_terminals = ['S','A','B']
		old_terminals = ['a','b']
		start = 'S'
		old_relations = [{'S',['A']}, {'A', ['a','B']}, {'B',['A','S','B']}, {'B',['b']},{'B',['a','b']}, {'A',['B']}, {'A',[]}]
		old_grammar = [old_non_terminals, old_terminals, start, old_relations]
		[_, _, _, new_relations] = Chomsky.remove_unit_relations(old_grammar)
		assert Enum.sort(new_relations) == 	Enum.sort([{'S',['a','B']},
													   {'S',['A','S','B']},
													   {'S',['b']},
													   {'S',['a','b']},
													   {'S',[]},
													   {'A',['a','B']}, 
													   {'B',['A','S','B']},
													   {'B',['b']},
													   {'B',['a','b']},
													   {'A',['A','S','B']},
													   {'A',['b']},
													   {'A',['a','b']},
													   {'A',[]}])
	end

	test "remove_unit_relations2" do
		old_non_terminals = ['S','A','B']
		old_terminals = ['a','b']
		start = 'S'
		old_relations = [{'S',['A']}, {'S', ['a','a']}, {'A', ['a','B']}, {'B',['A','S','B']}, {'B',['b']},{'B',['a','b']}, {'A',['B']},{'A', ['S']},{'A',[]}]
		old_grammar = [old_non_terminals, old_terminals, start, old_relations]
		[_, _, _, new_relations] = Chomsky.remove_unit_relations(old_grammar)
		assert Enum.sort(new_relations) == 	Enum.sort([{'S',['a','B']},
													   {'S',['A','S','B']},
													   {'S',['b']},
													   {'S',['a','b']},
													   {'S',[]},
													   {'S',['a','a']},
													   {'A',['a','B']}, 
													   {'B',['A','S','B']},
													   {'B',['b']},
													   {'B',['a','b']},
													   {'A',['A','S','B']},
													   {'A',['b']},
													   {'A',['a','b']},
													   {'A',['a','a']},
													   {'A',[]}])
	end

	test "remove_unit_relations3" do
		old_non_terminals = [:S,:A,:B]
		old_terminals = ['a','b']
		start = :S
		old_relations = [{:B, [:A,:A]}, {:A, [:B]}, {:B, [:S,'a']}]
		old_grammar = [old_non_terminals, old_terminals, start, old_relations]
		[_, _, _, new_relations] = Chomsky.remove_unit_relations(old_grammar)
		assert Enum.sort(new_relations)
	end

	test "remove_non_double_relations1" do
		old_non_terminals = [:S,:A,:B]
		old_terminals = ['a','b']
		start = :S
		old_relations = [{:S, [:A,:B]}, 
						 {:S, ['a',:B,:A]},
						 {:S, ['a','b',:A,'b']},
						 {:A, []},
						 {:B, ['a',:A,:B]}]
		old_grammar = [old_non_terminals, old_terminals, start, old_relations]
		[new_non_terminals, _, _, new_relations] = Chomsky.remove_non_double_relations(old_grammar)
		assert ({Enum.sort(new_non_terminals),Enum.sort(new_relations)} == {Enum.sort([:S,:A,:B,:q0,:q1,:q2,:q3]),
																			Enum.sort([{:S,  [:A,:B]}, 
												 									   {:S,  ['a',:q0]},
																			 		   {:q0, [:B,:A]},
																					   {:S,  ['a',:q1]},
																					   {:q1, ['b',:q2]},
																					   {:q2, [:A,'b']},
																			 		   {:A,  []},
																			 		   {:B,  ['a',:q3]},
																			 		   {:q3, [:A,:B]}])})
	end

	test "build_initial_table1" do
		assert (Chomsky.build_initial_table(3) == {{[],[],[]},
												   {[],[],[]},
												   {[],[],[]}})
	end

end
