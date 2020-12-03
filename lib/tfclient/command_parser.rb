module TFClient
  class CommandParser

    DIRECTION_MAP = {
      n: "6",
      ne: "7",
      e: "4",
      se: "2",
      s: "1",
      sw: "0",
      w: "3",
      nw: "5"
    }

    # 0: 315 degrees, X=-1, Y=-1 (northwest)
    # 1: 0 degrees, X=0, Y=-1 (north)
    # 2: 45 degrees, X=1, Y=-1 (northeast)
    # 3: 270 degrees, X=-1, Y=0 (west)
    # 4: 90 degrees, X=1, Y=0 (east)
    # 5: 225 degrees, X=-1, Y=1 (southwest)
    # 6: 180 degrees, X=0, Y=-1 (south)
    # 7: 135 degrees, X=1, Y=-1 (southeast)

    attr_reader :command
    def initialize(command:)
      @command = command
    end

    def parse
      if @command.length < 3 && (direction = DIRECTION_MAP[@command.to_sym])
        "jump #{direction}"
      else
        @command
      end
    end
  end
end