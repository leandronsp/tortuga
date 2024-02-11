require 'socket'
require_relative 'app/handler'

## TCP Server
socket = Socket.new(:INET, :STREAM) 
addr = Socket.pack_sockaddr_in(3000, '0.0.0.0')

## Bind the socket to the address
socket.bind(addr)
socket.listen(2)

puts "Listening on port 3000"

## Thread Queue
queue = Queue.new

## Thread Pool
thread_count = ENV['THREAD_POOL_SIZE'] || 5
thread_count.to_i.times do
  Thread.new do 
    loop do 
      client = queue.pop

      Handler.call(client)
      
      client.close
    end
  end
end

## Listen for incoming connections
loop do 
  client, _ = socket.accept

  ## Add client socket to the queue
  ## and let the threads handle it.
  ## Repeat the process.
  queue.push(client)
end
