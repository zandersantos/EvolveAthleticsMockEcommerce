# README
This Project will be used for the E-Commerce Project in the Fullstack Web Development Course in the Business Information Technology program at Red River College.

Author: Zander Santos
"Evolve Athletics" Fitness Equipment & Accessories Mock eCommerce Store

API's USED:
- https://wger.de/api/v2/equipment/

User:
  - A user will be able to navigate through available products by way of a front page and by category.
  - A user will be able to add various products to a shopping cart saved in a session, edit quantity of items in the shopping cart, and remove items from the cart.
  - A user will be able to complete a checkout process after filling their shopping cart and sign up for an account with a username and password.

Admin:
  - An admin will have access to an admin dashboard by provding a username and password.
  - An admin will be able to create/read/update/delete product listings, and product images by a way of an admin dashboard.
  - An admin will be able to edit the content of the website's contact and about page.
  -

## Models
1.  Customers: Stores information about all customers for purchases and orders:
  a.	CustomersID (Primary Key, Auto_Increment)
  b.	FirstName (String)
  c.	LastName (String)
  d.	EmailAddress (String)
  e.	PhoneNumber (String)

2.	ProductImages: Stores information about the product images:
  a.	ProductImagesID (Primary Key, Auto_Increment)
  b.	ImageURL (String)
  c.	ProductID (Foreign Key)

3.	Products: Stores the details of each product that will be sold:
  a.	ProductID (Primary Key, Auto_Increment)
  b.	Name (String)
  c.	Description (String)
  d.	Price (Float)
  e.	StockQuantity (Int)
  f.	CategoriesID (Foreign Key)

4.	Categories: Organizes products into groups, such as “Weight Plates” and “Dumbbells”:
  a.	CategoriesID
  b.	Category Name
  c.	Category Description

5.	Orders: Tracks the customer purchase information:
  a.	OrdersID
  b.	Total
  c.	OrderDate
  d.	CustomerID

6.	OrderDetails: Stores details of the products within each order:
  a.	OrderDetailsID
  b.	Quantity
  c.	PriceAtPurchase
  d.	OrdersID
  e.	ProductsID


## Routes
GET /                 => Homepage
GET /products         => Display a list of products
GET /products/:id     => Display a single product
GET /categories       => Display a list of categories
GET /categories/:id   => Display a single category
GET /orders/:id       => Display a single order
GET /pages/:permalink => Displays pages
GET /search_all       => Display a search results page


## Controllers
HomeController        => index
ProductsController    => index, show
CategoriesController  => index, show
OrdersController      => index, show
PagesController
SearchController