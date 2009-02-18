require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GuardTest < Test::Unit::TestCase
  def setup
    @guard = StateMachine::Guard.new(:to => :idling, :from => :parked)
  end
  
  def test_should_raise_exception_if_invalid_option_specified
    exception = assert_raise(ArgumentError) { StateMachine::Guard.new(:invalid => true) }
    assert_equal 'Invalid key(s): invalid', exception.message
  end
  
  def test_should_not_have_an_if_condition
    assert_nil @guard.if_condition
  end
  
  def test_should_not_have_an_unless_condition
    assert_nil @guard.unless_condition
  end
end

class GuardWithNoRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new
  end
  
  def test_should_use_all_matcher_for_event_requirement
    assert_equal StateMachine::AllMatcher.instance, @guard.event_requirement
  end
  
  def test_should_use_all_matcher_for_from_state_requirement
    assert_equal StateMachine::AllMatcher.instance, @guard.state_requirement[:from]
  end
  
  def test_should_use_all_matcher_for_to_state_requirement
    assert_equal StateMachine::AllMatcher.instance, @guard.state_requirement[:to]
  end
  
  def test_should_match_nil_query
    assert @guard.matches?(@object, nil)
  end
  
  def test_should_match_empty_query
    assert @guard.matches?(@object, {})
  end
  
  def test_should_match_non_empty_query
    assert @guard.matches?(@object, :to => :idling, :from => :parked, :on => :ignite)
  end
end

class GuardWithFromRequirementTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:from => :parked)
  end
  
  def test_should_use_a_whitelist_matcher
    assert_instance_of StateMachine::WhitelistMatcher, @guard.state_requirement[:from]
  end
  
  def test_should_match_if_not_specified
    assert @guard.matches?(@object, :to => :idling)
  end
  
  def test_should_match_if_included
    assert @guard.matches?(@object, :from => :parked)
  end
  
  def test_should_not_match_if_not_included
    assert !@guard.matches?(@object, :from => :idling)
  end
  
  def test_should_not_match_if_nil
    assert !@guard.matches?(@object, :from => nil)
  end
  
  def test_should_ignore_to
    assert @guard.matches?(@object, :from => :parked, :to => :idling)
  end
  
  def test_should_ignore_on
    assert @guard.matches?(@object, :from => :parked, :on => :ignite)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:parked], @guard.known_states
  end
end

class GuardWithMultipleFromRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:from => [:idling, :parked])
  end
  
  def test_should_match_if_included
    assert @guard.matches?(@object, :from => :idling)
  end
  
  def test_should_not_match_if_not_included
    assert !@guard.matches?(@object, :from => :first_gear)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:idling, :parked], @guard.known_states
  end
end

class GuardWithToRequirementTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:to => :idling)
  end
  
  def test_should_use_a_whitelist_matcher
    assert_instance_of StateMachine::WhitelistMatcher, @guard.state_requirement[:to]
  end
  
  def test_should_match_if_not_specified
    assert @guard.matches?(@object, :from => :parked)
  end
  
  def test_should_match_if_included
    assert @guard.matches?(@object, :to => :idling)
  end
  
  def test_should_not_match_if_not_included
    assert !@guard.matches?(@object, :to => :parked)
  end
  
  def test_should_not_match_if_nil
    assert !@guard.matches?(@object, :to => nil)
  end
  
  def test_should_ignore_from
    assert @guard.matches?(@object, :to => :idling, :from => :parked)
  end
  
  def test_should_ignore_on
    assert @guard.matches?(@object, :to => :idling, :on => :ignite)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:idling], @guard.known_states
  end
end

class GuardWithMultipleToRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:to => [:idling, :parked])
  end
  
  def test_should_match_if_included
    assert @guard.matches?(@object, :to => :idling)
  end
  
  def test_should_not_match_if_not_included
    assert !@guard.matches?(@object, :to => :first_gear)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:idling, :parked], @guard.known_states
  end
end

class GuardWithOnRequirementTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:on => :ignite)
  end
  
  def test_should_use_a_whitelist_matcher
    assert_instance_of StateMachine::WhitelistMatcher, @guard.event_requirement
  end
  
  def test_should_match_if_not_specified
    assert @guard.matches?(@object, :from => :parked)
  end
  
  def test_should_match_if_included
    assert @guard.matches?(@object, :on => :ignite)
  end
  
  def test_should_not_match_if_not_included
    assert !@guard.matches?(@object, :on => :park)
  end
  
  def test_should_not_match_if_nil
    assert !@guard.matches?(@object, :on => nil)
  end
  
  def test_should_ignore_to
    assert @guard.matches?(@object, :on => :ignite, :to => :parked)
  end
  
  def test_should_ignore_from
    assert @guard.matches?(@object, :on => :ignite, :from => :parked)
  end
  
  def test_should_not_be_included_in_known_states
    assert_equal [], @guard.known_states
  end
end

class GuardWithMultipleOnRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:on => [:ignite, :park])
  end
  
  def test_should_match_if_included
    assert @guard.matches?(@object, :on => :ignite)
  end
  
  def test_should_not_match_if_not_included
    assert !@guard.matches?(@object, :on => :shift_up)
  end
end

class GuardWithExceptFromRequirementTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:except_from => :parked)
  end
  
  def test_should_use_a_blacklist_matcher
    assert_instance_of StateMachine::BlacklistMatcher, @guard.state_requirement[:from]
  end
  
  def test_should_match_if_not_included
    assert @guard.matches?(@object, :from => :idling)
  end
  
  def test_should_not_match_if_included
    assert !@guard.matches?(@object, :from => :parked)
  end
  
  def test_should_match_if_nil
    assert @guard.matches?(@object, :from => nil)
  end
  
  def test_should_ignore_to
    assert @guard.matches?(@object, :from => :idling, :to => :parked)
  end
  
  def test_should_ignore_on
    assert @guard.matches?(@object, :from => :idling, :on => :ignite)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:parked], @guard.known_states
  end
end

class GuardWithMultipleExceptFromRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:except_from => [:idling, :parked])
  end
  
  def test_should_match_if_not_included
    assert @guard.matches?(@object, :from => :first_gear)
  end
  
  def test_should_not_match_if_included
    assert !@guard.matches?(@object, :from => :idling)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:idling, :parked], @guard.known_states
  end
end

class GuardWithExceptToRequirementTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:except_to => :idling)
  end
  
  def test_should_use_a_blacklist_matcher
    assert_instance_of StateMachine::BlacklistMatcher, @guard.state_requirement[:to]
  end
  
  def test_should_match_if_not_included
    assert @guard.matches?(@object, :to => :parked)
  end
  
  def test_should_not_match_if_included
    assert !@guard.matches?(@object, :to => :idling)
  end
  
  def test_should_match_if_nil
    assert @guard.matches?(@object, :to => nil)
  end
  
  def test_should_ignore_from
    assert @guard.matches?(@object, :to => :parked, :from => :idling)
  end
  
  def test_should_ignore_on
    assert @guard.matches?(@object, :to => :parked, :on => :ignite)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:idling], @guard.known_states
  end
end

class GuardWithMultipleExceptToRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:except_to => [:idling, :parked])
  end
  
  def test_should_match_if_not_included
    assert @guard.matches?(@object, :to => :first_gear)
  end
  
  def test_should_not_match_if_included
    assert !@guard.matches?(@object, :to => :idling)
  end
  
  def test_should_be_included_in_known_states
    assert_equal [:idling, :parked], @guard.known_states
  end
end

class GuardWithExceptOnRequirementTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:except_on => :ignite)
  end
  
  def test_should_use_a_blacklist_matcher
    assert_instance_of StateMachine::BlacklistMatcher, @guard.event_requirement
  end
  
  def test_should_match_if_not_included
    assert @guard.matches?(@object, :on => :park)
  end
  
  def test_should_not_match_if_included
    assert !@guard.matches?(@object, :on => :ignite)
  end
  
  def test_should_match_if_nil
    assert @guard.matches?(@object, :on => nil)
  end
  
  def test_should_ignore_to
    assert @guard.matches?(@object, :on => :park, :to => :idling)
  end
  
  def test_should_ignore_from
    assert @guard.matches?(@object, :on => :park, :from => :parked)
  end
  
  def test_should_not_be_included_in_known_states
    assert_equal [], @guard.known_states
  end
end

class GuardWithMultipleExceptOnRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:except_on => [:ignite, :park])
  end
  
  def test_should_match_if_not_included
    assert @guard.matches?(@object, :on => :shift_up)
  end
  
  def test_should_not_match_if_included
    assert !@guard.matches?(@object, :on => :ignite)
  end
end

class GuardWithConflictingFromRequirementsTest < Test::Unit::TestCase
  def test_should_raise_an_exception
    exception = assert_raise(ArgumentError) { StateMachine::Guard.new(:from => :parked, :except_from => :parked) }
    assert_equal 'Conflicting keys: from, except_from', exception.message
  end
end

class GuardWithConflictingToRequirementsTest < Test::Unit::TestCase
  def test_should_raise_an_exception
    exception = assert_raise(ArgumentError) { StateMachine::Guard.new(:to => :idling, :except_to => :idling) }
    assert_equal 'Conflicting keys: to, except_to', exception.message
  end
end

class GuardWithConflictingOnRequirementsTest < Test::Unit::TestCase
  def test_should_raise_an_exception
    exception = assert_raise(ArgumentError) { StateMachine::Guard.new(:on => :ignite, :except_on => :ignite) }
    assert_equal 'Conflicting keys: on, except_on', exception.message
  end
end

class GuardWithDifferentRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:from => :parked, :to => :idling, :on => :ignite)
  end
  
  def test_should_match_empty_query
    assert @guard.matches?(@object)
  end
  
  def test_should_match_if_all_requirements_match
    assert @guard.matches?(@object, :from => :parked, :to => :idling, :on => :ignite)
  end
  
  def test_should_not_match_if_from_not_included
    assert !@guard.matches?(@object, :from => :idling)
  end
  
  def test_should_not_match_if_to_not_included
    assert !@guard.matches?(@object, :to => :parked)
  end
  
  def test_should_not_match_if_on_not_included
    assert !@guard.matches?(@object, :on => :park)
  end
  
  def test_should_include_all_known_states
    assert_equal [:parked, :idling], @guard.known_states
  end
  
  def test_should_not_duplicate_known_statse
    guard = StateMachine::Guard.new(:except_from => :idling, :to => :idling, :on => :ignite)
    assert_equal [:idling], guard.known_states
  end
end

class GuardWithNilRequirementsTest < Test::Unit::TestCase
  def setup
    @object = Object.new
    @guard = StateMachine::Guard.new(:from => nil, :to => nil)
  end
  
  def test_should_match_empty_query
    assert @guard.matches?(@object)
  end
  
  def test_should_match_if_all_requirements_match
    assert @guard.matches?(@object, :from => nil, :to => nil)
  end
  
  def test_should_not_match_if_from_not_included
    assert !@guard.matches?(@object, :from => :parked)
  end
  
  def test_should_not_match_if_to_not_included
    assert !@guard.matches?(@object, :to => :idling)
  end
  
  def test_should_include_all_known_states
    assert_equal [nil], @guard.known_states
  end
end

class GuardWithIfConditionalTest < Test::Unit::TestCase
  def setup
    @object = Object.new
  end
  
  def test_should_have_an_if_condition
    guard = StateMachine::Guard.new(:if => lambda {true})
    assert_not_nil guard.if_condition
  end
  
  def test_should_match_if_true
    guard = StateMachine::Guard.new(:if => lambda {true})
    assert guard.matches?(@object)
  end
  
  def test_should_not_match_if_false
    guard = StateMachine::Guard.new(:if => lambda {false})
    assert !guard.matches?(@object)
  end
end

class GuardWithUnlessConditionalTest < Test::Unit::TestCase
  def setup
    @object = Object.new
  end
  
  def test_should_have_an_unless_condition
    guard = StateMachine::Guard.new(:unless => lambda {true})
    assert_not_nil guard.unless_condition
  end
  
  def test_should_match_if_false
    guard = StateMachine::Guard.new(:unless => lambda {false})
    assert guard.matches?(@object)
  end
  
  def test_should_not_match_if_true
    guard = StateMachine::Guard.new(:unless => lambda {true})
    assert !guard.matches?(@object)
  end
end

class GuardWithConflictingConditionalsTest < Test::Unit::TestCase
  def test_should_raise_an_exception
    exception = assert_raise(ArgumentError) { StateMachine::Guard.new(:if => lambda {true}, :unless => lambda {true}) }
    assert_equal 'Conflicting keys: if, unless', exception.message
  end
end

begin
  # Load library
  require 'rubygems'
  require 'graphviz'
  
  class GuardDrawingTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      states = [:parked, :idling]
      
      graph = GraphViz.new('G')
      states.each {|state| graph.add_node(state.to_s)}
      
      @guard = StateMachine::Guard.new(:from => :idling, :to => :parked)
      @edges = @guard.draw(graph, :park, states)
    end
    
    def test_should_create_edges
      assert_equal 1, @edges.size
    end
    
    def test_should_use_from_state_from_start_node
      assert_equal 'idling', @edges.first.instance_variable_get('@xNodeOne')
    end
    
    def test_should_use_to_state_for_end_node
      assert_equal 'parked', @edges.first.instance_variable_get('@xNodeTwo')
    end
    
    def test_should_use_event_name_as_label
      assert_equal 'park', @edges.first['label']
    end
  end
  
  class GuardDrawingWithFromRequirementTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      states = [:parked, :idling, :first_gear]
      
      graph = GraphViz.new('G')
      states.each {|state| graph.add_node(state.to_s)}
      
      @guard = StateMachine::Guard.new(:from => [:idling, :first_gear], :to => :parked)
      @edges = @guard.draw(graph, :park, states)
    end
    
    def test_should_generate_edges_for_each_valid_from_state
      [:idling, :first_gear].each_with_index do |from_state, index|
        edge = @edges[index]
        assert_equal from_state.to_s, edge.instance_variable_get('@xNodeOne')
        assert_equal 'parked', edge.instance_variable_get('@xNodeTwo')
      end
    end
  end
  
  class GuardDrawingWithExceptFromRequirementTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      states = [:parked, :idling, :first_gear]
      
      graph = GraphViz.new('G')
      states.each {|state| graph.add_node(state.to_s)}
      
      @guard = StateMachine::Guard.new(:except_from => :parked, :to => :parked)
      @edges = @guard.draw(graph, :park, states)
    end
    
    def test_should_generate_edges_for_each_valid_from_state
      %w(idling first_gear).each_with_index do |from_state, index|
        edge = @edges[index]
        assert_equal from_state, edge.instance_variable_get('@xNodeOne')
        assert_equal 'parked', edge.instance_variable_get('@xNodeTwo')
      end
    end
  end
  
  class GuardDrawingWithoutFromRequirementTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      states = [:parked, :idling, :first_gear]
      
      graph = GraphViz.new('G')
      states.each {|state| graph.add_node(state.to_s)}
      
      @guard = StateMachine::Guard.new(:to => :parked)
      @edges = @guard.draw(graph, :park, states)
    end
    
    def test_should_generate_edges_for_each_valid_from_state
      %w(parked idling first_gear).each_with_index do |from_state, index|
        edge = @edges[index]
        assert_equal from_state, edge.instance_variable_get('@xNodeOne')
        assert_equal 'parked', edge.instance_variable_get('@xNodeTwo')
      end
    end
  end
  
  class GuardDrawingWithoutToRequirementTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      
      graph = GraphViz.new('G')
      graph.add_node('parked')
      
      @guard = StateMachine::Guard.new(:from => :parked)
      @edges = @guard.draw(graph, :park, [:parked])
    end
    
    def test_should_create_loopback_edge
      assert_equal 'parked', @edges.first.instance_variable_get('@xNodeOne')
      assert_equal 'parked', @edges.first.instance_variable_get('@xNodeTwo')
    end
  end
rescue LoadError
  $stderr.puts 'Skipping GraphViz StateMachine::Guard tests. `gem install ruby-graphviz` and try again.'
end
