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
end
