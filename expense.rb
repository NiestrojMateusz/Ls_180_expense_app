require "pg"

class ExpenseData
  def initialize
    @connection = PG.connect(dbname: "expenses")
  end
  
  def list_expenses
    result = @connection.exec("SELECT * FROM expenses ORDER BY created_on ASC;")
    display_expenses(result)
  end

  def add_expense(amount, memo)
    date = Date.today
    sql = "INSERT INTO expenses (amount, memo, created_on) VALUES ($1, $2, $3)"
    @connection.exec_params(sql, [amount, memo, date])
  end
  
  def search_expense(query)
    sql = "SELECT * FROM expenses WHERE memo ILIKE $1"
    result = @connection.exec_params(sql, ["%#{query}%"])
    display_expenses(result)
  end
  
  private
  
  def display_expenses(result)
    result.each_row do |row| 
      puts "#{row[0].rjust(3)} | #{row[3].rjust(10)} | #{row[1].rjust(12)} | #{row[2]}" 
    end
  end
end

class CLI 
  def initialize
    @application = ExpenseData.new
  end
  
  def display_help
    help_content = <<~HELP 
    An expense recording system
    
    Commands:
  
    add AMOUNT MEMO [DATE] - record a new expense
    clear - delete all expenses
    list - list all expenses
    delete NUMBER - remove expense with id NUMBER
    search QUERY - list expenses with a matching memo field
    HELP
    
    puts help_content
  end
  
  def run(arguments)
    command = arguments.shift
    case command
    when "list"
      @application.list_expenses
    when "add"
      amount = arguments[0]
      memo = arguments[1]
      abort "You must provide an amount and memo." unless amount && memo
      @application.add_expense(amount, memo)
    when "search"
      query = arguments[0]
      @application.search_expense(query)
    else
      display_help
    end  
  end
end

CLI.new.run(ARGV)








