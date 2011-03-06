object Bookshelf
  def constructor(books)
    { 'ok, ref } = GenServer.start_link(Bookshelf::Server.new(books))
    { 'ref: ref }
  end

  def put(title)
    GenServer.cast(@ref, {'put, title})
  end

  def take(title)
    GenServer.call(@ref, {'take, title})
  end

  def see
    GenServer.call(@ref, 'see)
  end

  def burn
    GenServer.call(@ref, 'terminate)
  end

  object Server
    def constructor(books)
      { 'books: books }
    end

    def init
      { 'ok, self }
    end

    % Async message
    def handle_cast({'put, title})
      { 'noreply, self.set_ivar('books, [title|@books]) }
    end

    % Sync message
    def handle_call({'take, title}, _from)
      if @books.include?(title)
        { 'reply, 'ok, self.set_ivar('books, @books.delete(title)) }
      else
        { 'reply, 'not_found, self }
      end
    end

    def handle_call('see, _from)
      { 'reply, @books, self }
    end

    % Terminate sync message
    def handle_call('terminate, _from)
      { 'stop, 'normal, 'ok, self }
    end

    def handle_info(msg)
      IO.puts("Unexpected message: #{msg}\n")
      { 'no_reply, self }
    end

    def terminate('normal)
      @books.each -> (b) IO.puts("Oh no! \"#{b}\" is burning!")
      'ok
    end

    % Just do the code reloading
    def code_change(_old, _extra)
      { 'ok, self }
    end
  end
end

bookshelf = Bookshelf.new(["Crafting Rails Apps","Programming Erlang"])

bookshelf.put("Programming Elixir")
IO.puts "In the bookshelf: "
bookshelf.see.each -> (b) IO.puts "* #{b}"
IO.puts

bookshelf.take("Programming Erlang")
IO.puts "In the bookshelf: "
bookshelf.see.each -> (b) IO.puts "* #{b}"
IO.puts

bookshelf.burn