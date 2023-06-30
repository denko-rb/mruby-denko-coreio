#
# Copied as-is from CRuby gem.
#
module Denko
  module Motor
    class Stepper
      include Behaviors::MultiPin
      
      def initialize_pins(options={})
        proxy_pin :step,      DigitalIO::Output
        proxy_pin :direction, DigitalIO::Output
        
        proxy_pin :ms1,    DigitalIO::Output, optional: true
        proxy_pin :ms2,    DigitalIO::Output, optional: true
        proxy_pin :enable, DigitalIO::Output, optional: true
        proxy_pin :slp,    DigitalIO::Output, optional: true        
      end
      
      attr_reader :microsteps
                  
      def after_initialize(options={})
        wake; on;
        
        if (ms1 && ms2)
          self.microsteps = 8
        end
      end

      def sleep
        slp.low if slp
      end

      def wake
        slp.high if slp
      end

      def off
        enable.high if enable
      end

      def on
        enable.low if enable
      end

      def microsteps=(steps)
        if (ms1 && ms2)
          case steps.to_i
          when 1; ms2.low;  ms1.low
          when 2; ms2.low;  ms1.high
          when 4; ms2.high; ms1.low
          when 8; ms2.high; ms1.high
          end
        else
          raise ArgumentError, "ms1 and ms2 pins must be connected to GPIO pins to control microstepping."
        end
        @microsteps = steps
      end

      def step_cc
        direction.high unless direction.high?
        step.high
        step.low
      end

      def step_cw
        direction.low unless direction.low?
        step.high
        step.low
      end

      alias :step_ccw :step_cc
    end
  end
end
