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
    [['S0'|nonterminals], terminals, :S0, [{:S0,[start]} | relations]]
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

  def check_null_nonterminals([], _) do
     false
  end

  def check_null_nonterminals(rhs, list_of_null_nonterminals) do
    [head|tail] = rhs
    if inList(head, list_of_null_nonterminals) do
      true
    else
      check_null_nonterminals(tail, list_of_null_nonterminals)
    end
  end

  #-------------------------------------------------------------------------------------------

  def clean_empty_rules([]) do
    []
  end

  def clean_empty_rules(relations) do
    [head_relation|tail_relation] = relations
    {_,rhs} = head_relation
    if rhs == [] do
      clean_empty_rules(tail_relation)
    else
      [head_relation|clean_empty_rules(tail_relation)]
    end
  end

  #-------------------------------------------------------------------------------------------

  def get_empty_rules(relations, no_empty_relations \\ [], empty_rule_lhs \\ [])

  def get_empty_rules([], no_empty_relations, empty_rule_lhs) do
    {no_empty_relations, empty_rule_lhs}
  end

  def get_empty_rules(relations, no_empty_relations, empty_rule_lhs) do
    [head_relation|tail_relation] = relations
    {lhs,rhs} = head_relation
    if rhs == [] do
      if inList(lhs, empty_rule_lhs) == false do
        get_empty_rules(appendList(no_empty_relations,tail_relation), [], [lhs|empty_rule_lhs]) 
      else
        get_empty_rules(tail_relation, no_empty_relations, empty_rule_lhs)
      end
    else
      if check_null_nonterminals(rhs,empty_rule_lhs) do
        if inList(lhs, empty_rule_lhs) == false do
          get_empty_rules(appendList([head_relation|no_empty_relations], tail_relation), [], [lhs|empty_rule_lhs])
        else
          get_empty_rules(tail_relation, [head_relation|no_empty_relations], empty_rule_lhs)
        end
      else
        get_empty_rules(tail_relation, [head_relation|no_empty_relations], empty_rule_lhs)  
      end
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
    new_relations = derivate_empty_relations(non_empty_relations, empty_left_sides) # Get a new list of relations, given list of empty left_sides
    [nonterminals, terminals, start, clean_empty_rules(new_relations)]
  end

  #-------------------------------------------------------------------------------------------

  def derivate_unit_relations(_, [], _) do
    []
  end

  def derivate_unit_relations(unit_relation, relations, seen) do
    [head_relation | tail_relation] = relations
    {unit_lhs, [unit_rhs]} = unit_relation
    {head_lhs, head_rhs} = head_relation
    if head_lhs == unit_rhs do
      proposed_relation = {unit_lhs, head_rhs}
      if inList(proposed_relation, seen) do
        derivate_unit_relations(unit_relation, tail_relation, seen)
      else
        [proposed_relation|derivate_unit_relations(unit_relation, tail_relation, [proposed_relation|seen])]
      end
    else
      derivate_unit_relations(unit_relation, tail_relation, seen)
    end
  end

  #-------------------------------------------------------------------------------------------

  def get_unit_relations(relations, nonterminals, seen \\ [])

  def get_unit_relations([],_,seen) do
    seen
  end

  def get_unit_relations(relations, nonterminals, seen) do
    [head_relation|tail_relation] = relations
    {_,rhs} = head_relation
    if Enum.count(rhs) == 1 do
      [head_char | _ ] = rhs
      if inList(head_char, nonterminals) do
        derivate_unit_relations(head_relation, appendList(seen,tail_relation), seen) |> appendList(tail_relation) |> get_unit_relations(nonterminals, seen)
      else
        if inList(head_relation, seen) do
          get_unit_relations(tail_relation, nonterminals, seen)
        else
          get_unit_relations(tail_relation, nonterminals, [head_relation|seen])
        end
      end
    else
      if inList(head_relation, seen) do
        get_unit_relations(tail_relation, nonterminals, seen)
      else
        get_unit_relations(tail_relation, nonterminals, [head_relation|seen])
      end
    end

  end

 #-------------------------------------------------------------------------------------------

  def remove_unit_relations(old_grammar) do
     [nonterminals , terminals, start, relations] = old_grammar
     [nonterminals, terminals, start, get_unit_relations(relations, nonterminals)]
  end

  #-------------------------------------------------------------------------------------------

  def get_double_relations(nonterminals, relations, additional_state_aux \\ 0, new_relations \\ [])

  def get_double_relations(nonterminals, [], _, new_relations) do
    {nonterminals, new_relations}
  end

  def get_double_relations(nonterminals, relations, additional_state_aux, new_relations) do
    [head_relation|tail_relation] = relations
    {lhs, rhs} = head_relation
    if Enum.count(rhs) > 2 do
      [head_char | tail_char] = rhs
      new_state = String.to_atom("q" <> Integer.to_string(additional_state_aux))
      new_relation = {lhs,[head_char | [new_state]]} 
      get_double_relations([new_state|nonterminals],
                           [{new_state, tail_char} | tail_relation], 
                           additional_state_aux+1,
                           [new_relation|new_relations])
    else 
      get_double_relations(nonterminals,
                           tail_relation,
                           additional_state_aux,
                           [head_relation|new_relations])
    end
  end

  #-------------------------------------------------------------------------------------------

  def remove_non_double_relations(old_grammar) do
    [nonterminals , terminals, start, relations] = old_grammar
    {new_non_terminals, new_relations} = get_double_relations(nonterminals, relations)
    [new_non_terminals, terminals, start, new_relations]
  end


  #-------------------------------------------------------------------------------------------

  def get_non_terminals_relations(nonterminals, terminals, relations, additional_state_aux \\ 0, new_relations \\ [])

  def get_non_terminals_relations(nonterminals, _, [], _, new_relations) do
    {nonterminals, new_relations}
  end

  def get_non_terminals_relations(nonterminals, terminals,  relations, additional_state_aux, new_relations) do
    [head_relation|tail_relation] = relations
    {lhs, rhs} = head_relation
    new_state = String.to_atom("r" <> Integer.to_string(additional_state_aux))
    if Enum.count(rhs) > 1 do
      [first | [second]] = rhs
      if inList(first, terminals) do 
        new_relation1 = {lhs, [new_state | [second]]}
        new_relation2 = {new_state, [first]}
        get_non_terminals_relations([new_state|nonterminals],
                                    terminals,
                                    [new_relation1|tail_relation],
                                    additional_state_aux + 1,
                                    [new_relation2|new_relations])
      else
        if inList(second,terminals) do
          new_relation1 = {lhs, [first | [new_state]]}
          new_relation2 = {new_state, [second]}
          get_non_terminals_relations([new_state|nonterminals],
                                      terminals,
                                      tail_relation,
                                      additional_state_aux + 1,
                                      [new_relation1|[new_relation2|new_relations]])
        else
          get_non_terminals_relations(nonterminals,
                                      terminals,
                                      tail_relation,
                                      additional_state_aux,
                                      [head_relation|new_relations])
        end
      end
    else
      get_non_terminals_relations(nonterminals,
                                  terminals,
                                  tail_relation,
                                  additional_state_aux,
                                  [head_relation|new_relations])

    end
  end
  #-------------------------------------------------------------------------------------------

  def remove_non_non_terminals_relations(old_grammar) do
    [nonterminals , terminals, start, relations] = old_grammar
    {new_non_terminals, new_relations} = get_non_terminals_relations(nonterminals, terminals, relations)
    [new_non_terminals, terminals, start, new_relations]
  end  

  #-------------------------------------------------------------------------------------------

  def chomsky_normal_form(old_grammar) do
  
  # nonterminals = [coisas] ['A' , 'B', 'S']
  # terminais = [coisas] ['a','b']
  # start = coisa, sendo coisa pertencente a nonterminals 'S' 
  # relations = [relation] [{'S',['b','S','A']}, {'A',['a']}]
  # relation = {origem, destino} {'S',['b','S','A']} 'S' -> ['b','S','A']
    new_start_state(old_grammar) |> remove_empty_relations() |> remove_unit_relations() |> remove_non_double_relations() |> remove_non_non_terminals_relations()
  end

  #-------------------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------------------


  #-------------------------------------------------------------------------------------------

  
  #-------------------------------------------------------------------------------------------

  def get_alfas_of_relations_with_betas(beta, relations) do
    # dada relações do tipo alfa -> beta, retorna uma lista de alfas que virem o beta passado

  end

  #-------------------------------------------------------------------------------------------
  def build_table([], _, table) do
    table
  end

  def build_table(string, grammar, table \\ {}) do 
  # vamos passar por aqui size vezes, de 0 a size-1 colunas
    [head_char | tail_string] = string
    [nonterminals , terminals, start, relations] = grammar
    alfas = get_alfas_of_relations_with_betas(head_char, relations)


    build_table(tail_string, grammar, table)
    #initial_table = build_initial_table(string, size, grammar)
  end

  #-------------------------------------------------------------------------------------------

  def build_initial_table(size, i \\ 0, row \\ {}) do
    # cria a tabela inicial de tamanho sizeXsize, ou seja, se a string for de tamanho 3
    # initial_table = {{[],[],[]},
    #                  {[],[],[]},
    #                  {[],[],[]}}
    if (i < size) do
      IO.puts('i')
      IO.puts(i)
      IO.puts('row')
      #IO.puts(row)
      row = Tuple.insert_at(row, i, [])
      build_initial_table(size, i+1, row)
    else
      Tuple.duplicate(row, size) # retorna a linha multiplicada pelo tamanho dentro de uma tupla
    end
  end


  #-------------------------------------------------------------------------------------------

  def string_recon(string, grammar) do
    initial_table = build_initial_table(length(string))
    table = build_table(string, grammar, initial_table)
    if (elem(table,0) |> elem(length(string)) == []) do
      false
    else
      true
    end
  end


 

































end