require 'state_machine/transition'
require 'state_machine/guard'
require 'state_machine/assertions'

module PluginAWeek #:nodoc:
  module StateMachine
    # An event defines an action that transitions an attribute from one state to
    # another.  The state that an attribute is transitioned to depends on the
    # guards configured for the event.
    class Event
      include Assertions
      
      # The state machine for which this event is defined
      attr_accessor :machine
      
      # The name of the action that fires the event
      attr_reader :name
      
      # The list of guards that determine what state this event transitions
      # objects to when fired
      attr_reader :guards
      
      # Creates a new event within the context of the given machine
      def initialize(machine, name) #:nodoc:
        @machine = machine
        @name = name
        @guards = []
        
        add_actions
      end
      
      # Creates a copy of this event in addition to the list of associated
      # guards to prevent conflicts across different events.
      def initialize_copy(orig) #:nodoc:
        super
        @guards = @guards.dup
        @known_states = nil
      end
      
      # Gets a list of all of the states known to this event.  This will look at
      # each guard's known states are compile a union of those states.
      def known_states
        @known_states ||= guards.inject([]) {|states, guard| states |= guard.known_states}
      end
      
      # Creates a new transition that will be evaluated when the event is fired.
      # 
      # Configuration options:
      # * +to+ - The state that being transitioned to.  If not specified, then the transition will not change the state.
      # * +from+ - A state or array of states that can be transitioned from. If not specified, then the transition can occur for *any* from state
      # * +except_from+ - A state or array of states that *cannot* be transitioned from.
      # * +if+ - Specifies a method, proc or string to call to determine if the transition should occur (e.g. :if => :moving?, or :if => Proc.new {|car| car.speed > 60}). The method, proc or string should return or evaluate to a true or false value.
      # * +unless+ - Specifies a method, proc or string to call to determine if the transition should not occur (e.g. :unless => :stopped?, or :unless => Proc.new {|car| car.speed <= 60}). The method, proc or string should return or evaluate to a true or false value.
      # 
      # == Order of operations
      # 
      # Transitions are evaluated in the order in which they're defined.  As a
      # result, if more than one transition applies to a given object, then the
      # first transition that matches will be performed.
      # 
      # == Dynamic states
      # 
      # There is limited support for using dynamically generated values for the
      # +to+ state in transitions.  This is especially useful for times where
      # the machine attribute represents a Time object.  In order to have a
      # a transition be made to the current time, a lambda block can be passed
      # in representing the state, such as:
      # 
      #   transition :to => lambda {Time.now}
      # 
      # == Examples
      # 
      #   transition :from => %w(first_gear reverse)
      #   transition :except_from => 'parked'
      #   transition :to => 'parked'
      #   transition :to => lambda {Time.now}
      #   transition :to => 'parked', :from => 'first_gear'
      #   transition :to => 'parked', :from => %w(first_gear reverse)
      #   transition :to => 'parked', :from => 'first_gear', :if => :moving?
      #   transition :to => 'parked', :from => 'first_gear', :unless => :stopped?
      #   transition :to => 'parked', :except_from => 'parked'
      def transition(options)
        assert_valid_keys(options, :to, :from, :except_from, :if, :unless)
        
        guards << guard = Guard.new(options)
        guard
      end
      
      # Determines whether any transitions can be performed for this event based
      # on the current state of the given object.
      # 
      # If the event can't be fired, then this will return false, otherwise true.
      def can_fire?(object)
        !next_transition(object).nil?
      end
      
      # Finds and builds the next transition that can be performed on the given
      # object.  If no transitions can be made, then this will return nil.
      def next_transition(object)
        from = object.send(machine.attribute)
        
        if guard = guards.find {|guard| guard.matches?(object, :from => from)}
          # Guard allows for the transition to occur
          to = guard.requirements[:to] || from
          to = to.call if to.is_a?(Proc)
          Transition.new(object, machine, name, from, to)
        end
      end
      
      # Attempts to perform the next available transition on the given object.
      # If no transitions can be made, then this will return false, otherwise
      # true.
      def fire(object, *args)
        if transition = next_transition(object)
          transition.perform(*args)
        else
          false
        end
      end
      
      protected
        # Add the various instance methods that can transition the object using
        # the current event
        def add_actions
          attribute = machine.attribute
          name = self.name
          
          machine.owner_class.class_eval do
            # Checks whether the event can be fired on the current object
            define_method("can_#{name}?") do
              self.class.state_machines[attribute].events[name].can_fire?(self)
            end
            
            # Gets the next transition that would be performed if the event were to be fired now
            define_method("next_#{name}_transition") do
              self.class.state_machines[attribute].events[name].next_transition(self)
            end
            
            # Fires the event
            define_method(name) do |*args|
              self.class.state_machines[attribute].events[name].fire(self, *args)
            end
            
            # Fires the event, raising an exception if it fails to transition
            define_method("#{name}!") do |*args|
              send(name, *args) || raise(PluginAWeek::StateMachine::InvalidTransition, "Cannot transition via :#{name} from #{send(attribute).inspect}")
            end
          end
        end
    end
  end
end
