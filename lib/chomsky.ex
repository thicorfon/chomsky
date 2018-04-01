defmodule Chomsky do

  def inList(_, []) do
    false
  end

  def inList(member, [head|tail]) do
    if member == head do
      true
    else
      inList(member, tail)
    end
  end

  def getDistincts([]) do
    []
  end

  def getDistincts([head|tail])do
    if inList(head,tail) == true do
      getDistincts(tail)
    else
      [head|getDistincts(tail)]
    end
  end

  def appendList([],list) do
    list
  end

  def appendList([head|tail], list) do
    [head|appendList(tail,list)]
  end

  #-------------------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------------------

  def new_start_state(old_grammar) do
    [nonterminals , terminals, start, relations] = old_grammar
    [['S0'|nonterminals], terminals, 'S0', [{'S0',[start]} | relations]]
  end

  #-------------------------------------------------------------------------------------------

  def clean_empty([]) do
    []
  end

  def clean_empty(string) do
    [head|tail] =  string
    if head == [] do
      clean_empty(tail)
    else
      [head|clean_empty(tail)]
    end
  end

  #-------------------------------------------------------------------------------------------

  def get_empty_rules(relations, no_empty_relations \\ [], empty_rule_lsh \\ [])

  def get_empty_rules([], no_empty_relations, empty_rule_lsh) do
    {no_empty_relations, empty_rule_lsh}   
  end

  def get_empty_rules(relations, no_empty_relations, empty_rule_lhs) do
    [head | tail] = relations
    {lhs, rhs} = head
    if rhs == [] do
      get_empty_rules(tail, no_empty_relations, [lhs | empty_rule_lhs] )
    else
      get_empty_rules(tail, [head|no_empty_relations], empty_rule_lhs)
    end
  end

  #-------------------------------------------------------------------------------------------

  def apply_empty_relations(head_relation,char, seen \\ [])

  def apply_empty_relations({lhs,[]}, _, seen) do
    [{lhs, seen}] 
  end

  def apply_empty_relations({lhs, rhs}, char, seen) do
    [head_char|tail] = rhs
    if head_char == char do
      appendList(apply_empty_relations({lhs,tail}, char, seen ++ [head_char]), apply_empty_relations({lhs,tail}, char, seen))
    else
      apply_empty_relations({lhs,tail}, char, seen ++ [head_char])
    end
  end

  #-------------------------------------------------------------------------------------------

  def get_new_relations([],_) do
    []
  end

  def get_new_relations(old_relations,char) do
    # Receives a char and the list of old_relations, and returns a list of relations containing derivated relations
    [head_relation|tail_relation] = old_relations #
    new_relations = getDistincts(apply_empty_relations(head_relation,char)) # 
    appendList(new_relations,get_new_relations(tail_relation,char))
  end

  #-------------------------------------------------------------------------------------------

  def derivate_empty_relations(old_relations,[]) do
    old_relations
  end

  def derivate_empty_relations(old_relations, empty_left_sides) do
    # Receives the old relations and list of characters that have empty transitions and returns a list containing all new relations
    # [{'S',['A']}, {'A', ['a','B']}, {'B',['A']}, {'B',['b']}] , ['A'] -> 
    # [{'S',['A']}, {'S',[]}, {'A', ['a','B']}, {'B',['A']}, {'B',[]}, {'B',['b']} ], [] 
    # ------------------
    # [{'S',['A']}, {'A', ['a','B']}, {'B',['A']}, {'B',['b']} ], ['S','B'] ->
    # [{'S',['A']}, {'A', ['a','B']}, {'B',['A']}, {'B',[]}, {'B',['b']} ], ['B'] ->
    # [{'S',['A']}, {'A', ['a','B']}, {'A', ['a']}, {'B',['A']}, {'B',['b']} ], []
    [head_empty_left_sides | tail_empty_left_sides] = empty_left_sides
    get_new_relations(old_relations,head_empty_left_sides) |> getDistincts() |> derivate_empty_relations(tail_empty_left_sides)
  end

  #-------------------------------------------------------------------------------------------

  def remove_empty_relations(old_grammar) do
    # Receives a grammar a return a grammar without empty relations
    # [{'S',['A']}, {'A',[]}, {'A', ['a','B']}, {'B',['A']}, {'B',['b']} ]
    # [{'S',['A']}, {'A', ['a','B']}, {'A', ['a']} , {'B',['A']}, {'B',['b']} ]
    [nonterminals , terminals, start, relations] = old_grammar
    {non_empty_relations, empty_left_sides} = get_empty_rules(relations) # Characters that have an empty relation
    if empty_left_sides == [] do # if none, returns the grammar received
      old_grammar
    else
      new_relations = derivate_empty_relations(non_empty_relations, empty_left_sides) # Get a new list of relations, given list of empty left_sides
      remove_empty_relations([nonterminals , terminals, start, new_relations]) # Run again
    end
  end

  #-------------------------------------------------------------------------------------------

  def remove_unit_relations(old_grammar) do
    
  end

  #-------------------------------------------------------------------------------------------

  def remove_non_double_relations(old_grammar) do
    
  end

  #-------------------------------------------------------------------------------------------

  def chomsky_normal_form(old_grammar) do
  
  # nonterminals = [coisas] ['A' , 'B', 'S']
  # terminais = [coisas] ['a','b']
  # start = coisa, sendo coisa pertencente a nonterminals 'S' 
  # relations = [relation] [{'S',['b','S','A']}, {'A',['a']}]
  # relation = {origem, destino} {'S',['b','S','A']} 'S' -> ['b','S','A']
    new_start_state(old_grammar) |> remove_empty_relations() |> remove_unit_relations() |> remove_non_double_relations()
  end

end
