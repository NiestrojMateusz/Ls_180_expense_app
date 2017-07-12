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
  
  def delete_expense(expense_id)
    sql = "SELECT * FROM expenses WHERE id = $1"
    result = @connection.exec_params(sql, [expense_id])
    if result.ntuples == 0
      puts "There is no expense with the id: #{expense_id}" 
    else
      sql = "DELETE FROM expenses WHERE id=$1"
      @connection.exec_params(sql, ["#{expense_id}"])
      
      puts "The following expense has been deleted:"
      display_expenses(result)
    end
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
    when "delete"
      expense_id = arguments[0]
      @application.delete_expense(expense_id)
    else
      display_help
    end  
  end
end

CLI.new.run(ARGV)








