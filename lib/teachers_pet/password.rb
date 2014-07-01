require 'termios'

class Password < String
  def self.echo(on=true)
    term = Termios::getattr( $stdin )

    if on
      term.c_lflag |= ( Termios::ECHO | Termios::ICANON )
    else # off
      term.c_lflag &= ~Termios::ECHO
    end

    Termios::setattr( $stdin, Termios::TCSANOW, term )
  end

  def self.get(message="Password: ")
    begin
      if $stdin.tty?
        Password.echo false
        print message if message
      end

      pw = Password.new( $stdin.gets || "" )
      pw.chomp!

    ensure
      if $stdin.tty?
        Password.echo true
        print "\n"
      end
    end
  end
end
