import Foundation

print("demo application started")

let program = CredentialsHTTP()
program.get_order_request() // this function returns all open orders
//program.place_order_request() // this function creates a new order
//program.cancel_order_request() // this function cancels an existing order
