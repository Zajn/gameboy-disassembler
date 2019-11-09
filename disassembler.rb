# frozen_string_literal: true

class Disassembler
  attr_reader :rom
  attr_accessor :address

  OPCODE_MAP = {
    '31' => { instruction: "LD SP, %s", size: 2 },
    'af' => { instruction: "XOR A", size: 0 },
    '21' => { instruction: "LD HL, %s", size: 2 },
    '32' => { instruction: "LDD HL, A", size: 0 },
    'cb7c' => { instruction: "BIT 7, H", size: 0 },
    '20' => { instruction: "JR NZ, %s", size: 1 },
    '0e' => { instruction: "LD C, %s", size: 1 }
  }

  def initialize(path_to_rom)
    @rom = File.open(path_to_rom)
  end

  def disassemble
    until rom.eof?
      buffer = rom.readbyte.to_s(16)

      # Check for extended instructions
      buffer << rom.readbyte.to_s(16) if buffer == 'cb'

      if OPCODE_MAP[buffer]
        instruction = OPCODE_MAP[buffer][:instruction]
        size = OPCODE_MAP[buffer][:size]

        arguments = []
        size.times do
          arguments.push(rom.readbyte.to_s(16))
        end

        # CPU is little endian, so data will be stored
        # least-significant byte first.
        puts format(instruction, arguments.reverse.join(''))
      end
    end

    rom.close
  end
end
