# SAP Webshop – Spac_SAP

A webshop developed using SAP ABAP Cloud technologies, demonstrating the use of RAP, CDS, OData V4, SAP Fiori Elements and custom SAPUI5 development.

The project was developed as a learning project to explore SAP application development, backend architecture, business logic and frontend integration.

## 1. Project Overview

The application is a webshop with product browsing, multiple currencies, shopping cart management and inventory handling.

The backend is built using the ABAP RESTful Application Programming Model (RAP), while the frontend combines SAP Fiori Elements with a custom SAPUI5 application.

The project is divided into two main parts:

- **Backend (`src/`)** – Database tables, CDS views, RAP Business Objects, ABAP classes and OData services.
- **Frontend (`ui/`)** – A custom SAPUI5 application for browsing products and managing shopping carts.

### Main Features

- Product catalog with product images and descriptions.
- Product prices in multiple currencies (DKK and EUR).
- Product and warehouse management.
- Inventory management across multiple warehouses.
- Shopping cart creation and management.
- Automatic calculation of item totals and cart totals.
- Stock validation and allocation during checkout.
- Draft support for editing backend data.

Checkout is a demonstration of order processing and inventory allocation. Payment processing is not implemented.

## 2. Technologies

| Technology | Purpose |
|---|---|
| ABAP Cloud | Backend programming language and environment |
| SAP RAP | Business Objects and business logic |
| CDS | Data modelling, relationships and metadata |
| OData V4 | Communication between frontend and backend |
| SAP Fiori Elements | Metadata-driven user interfaces |
| SAPUI5 | Custom frontend development |
| abapGit | Version control and backend object import |
| Node.js / npm | Frontend development and deployment tooling |

## 3. Architecture

The application follows a layered architecture:

```text
Frontend
  |
  |-- Custom SAPUI5 Webshop
  |
  v
OData V4 Services
  |
  |-- Product Catalog & Shopping Cart
  |-- Product, Price, Stock & Warehouse Management
  |
  v
RAP Business Objects
  |
  |-- Behavior Definitions
  |-- Behavior Implementations
  |-- Validations and Determinations
  |
  v
CDS Data Models
  |
  v
Database Tables
```

### Main Business Objects

| Business Object | Description |
|---|---|
| Product | Product information and descriptions |
| Product Price | Product prices in different currencies |
| Warehouse | Warehouse locations and information |
| Stock | Product quantities at individual warehouses |
| Shopping Cart | Customer shopping carts |
| Shopping Cart Item | Individual products and quantities within a cart |
| Stock Allocation | Inventory allocations made during checkout |

Shopping Cart is structured as a root entity with Shopping Cart Items as child entities. Product and warehouse information is connected through CDS associations.

## 4. Repository Structure

```text
Spac_SAP/
│
├── .abapgit.xml
├── README.md
│
├── src/
│   ├── Database tables
│   ├── CDS views and metadata extensions
│   ├── Behavior definitions
│   ├── ABAP classes
│   ├── Service definitions
│   └── Service bindings
│
└── ui/
    └── zspac103_shop/
        ├── webapp/
        │   ├── ext/
        │   ├── annotations/
        │   ├── localService/
        │   └── manifest.json
        │
        ├── package.json
        ├── package-lock.json
        ├── ui5.yaml
        ├── ui5-local.yaml
        ├── ui5-mock.yaml
        └── ui5-deploy.yaml
```

### Backend – `src/`

Contains the ABAP development objects.

The `.abapgit.xml` configuration specifies `/src/` as the starting folder for abapGit. The frontend application is therefore not included when importing the repository through abapGit.

### Frontend – `ui/zspac103_shop/`

Contains the custom SAPUI5 application.

The application uses SAP Fiori Elements templates together with custom controllers and views.

The `ext/` folder contains custom functionality for the product catalog and shopping cart.

Frontend dependencies and development scripts are defined in `package.json`.

## 5. Prerequisites

### Backend

- Access to an SAP BTP ABAP Environment.
- Eclipse with ABAP Development Tools (ADT).
- abapGit installed and configured.
- Permission to create or import objects into package `ZSPAC103`.
- Permission to activate and publish OData service bindings.

### Frontend

- Node.js (LTS version).
- npm.
- Access to the SAP backend used by the application.
- Appropriate SAP credentials and permissions for the backend and deployment environment.

## 6. Backend Setup

### Step 1 – Import the repository

Clone the repository using abapGit:

```text
https://github.com/Kajs/Spac_SAP.git
```

Import the repository into the package:

```text
ZSPAC103
```

The repository contains the abapGit configuration needed to import the objects from `src/`.

### Step 2 – Activate the objects

Activate the imported objects in ADT.

Depending on the import and activation order, some objects may need to be activated separately after their dependencies are available.

A suggested order is:

1. Database tables and data elements.
2. CDS interface views and related data models.
3. RAP Behavior Definitions and implementations.
4. CDS projection views and projection behaviors.
5. Service Definitions.
6. Service Bindings.

Resolve any activation errors before continuing.

### Step 3 – Publish OData services

The following service bindings are used by the project:

- `ZUI_SPAC103_PRODUCT_Q_O4`
- `ZUI_SPAC103_STOCK_O4`

Open the corresponding Service Bindings in ADT and make sure the OData V4 services are published and available.

### Step 4 – Load example data

The project includes the ABAP console class:

```text
ZCL_SPAC103_DATA_LOADER
```

Run the class from ADT as an ABAP application console.

It inserts example data into:

| Table | Example data |
|---|---|
| `ZSPAC103_PRODUCT` | 5 products |
| `ZSPAC103_P_PRICE` | Prices in DKK and EUR |
| `ZSPAC103_WAREHOU` | 3 warehouses |
| `ZSPAC103_STOCK` | Stock quantities distributed across warehouses |

**Important:** The Data Loader performs cleanup before inserting data. It deletes all existing entries from the four tables listed above.

This means existing product, price, warehouse and stock data will be removed.

The cleanup does not reset the shopping cart tables or all other project data. It should only be executed in a development or test environment where the affected data can safely be replaced.

### Optional – RAP validation test

The repository also contains:

```text
ZCL_SPAC103_RAP_TESTER
```

This console class tests stock creation and update through RAP.

It includes a test of the stock amount validation, where a negative amount should be rejected.

The test uses warehouse ID `99` and product ID `99` for its test record.

## 7. Frontend Setup – Custom SAPUI5 Application

The custom webshop is located in:

```text
ui/zspac103_shop
```

Unlike the backend, this application must be installed and deployed separately.

### Step 1 – Install dependencies

Open a terminal in the application directory:

```bash
cd ui/zspac103_shop
```

Install the required dependencies:

```bash
npm ci
```

### Step 2 – Configure the backend connection

The UI5 application currently contains a reference to the SAP backend used during development.

Before connecting to another SAP system, the backend URL must be updated in the relevant configuration files:

| File | Purpose |
|---|---|
| `ui5.yaml` | Main local development configuration |
| `ui5-local.yaml` | Alternative local development configuration |
| `ui5-mock.yaml` | Local configuration with mock server |
| `ui5-deploy.yaml` | Deployment target configuration |

Replace the existing backend hostname with the hostname of the SAP system being used.

The `manifest.json` also contains the OData V4 service path:

```text
/sap/opu/odata4/sap/zui_spac103_product_q_o4/srvd/sap/zui_spac103_product_q_sd/0001/
```

This path should normally remain unchanged if the same service names and versions are used in the target system. Otherwise, update it to match the published service.

The local development proxy uses SAP authentication configuration. Depending on the target environment, the authentication settings may need adjustments.

Do not store passwords, authentication tokens or other credentials in the repository.

### Step 3 – Start the application locally

Start the application using:

```bash
npm start
```

This starts the SAP Fiori development server and opens the application preview.

Other scripts are available in `package.json`:

| Command | Description |
|---|---|
| `npm start` | Starts the application using `ui5.yaml`. |
| `npm run start-local` | Starts using the alternative local configuration. |
| `npm run start-mock` | Starts using the mock server configuration. |
| `npm run build` | Builds the application. |
| `npm run deploy` | Builds and deploys the application to SAP. |
| `npm run undeploy` | Removes the deployed application. |

The mock server can be used for frontend development without relying on live backend data. It does not replace the actual RAP implementation.

### Step 4 – Deploy to SAP

The project includes a deployment configuration in:

```text
ui5-deploy.yaml
```

The current configuration uses:

| Setting | Value |
|---|---|
| Application name | `ZSPAC103_SHOP` |
| Package | `ZSPAC103` |
| Description | Webshop application |

Update the deployment target URL to match the intended SAP system.

To deploy:

```bash
npm run deploy
```

Deployment requires appropriate SAP permissions and a working authentication setup.

### Launchpad Registration and Access Management

The repository includes the following Launchpad and IAM objects:

| Object | Description |
|---|---|
| `ZSPAC103_SHOP_UI5R` | Launchpad App Descriptor Item for the custom UI5 application. |
| `ZSPAC103_SHOP_IAM_EXT` | IAM External App connecting the UI5 application with its backend service and authorization settings. |
| `ZSPAC103_SHOP_BC` | Business Catalog containing the webshop application. |

These objects are used to integrate the webshop with SAP Fiori Launchpad and manage user access, but since the relevant app to set user permissions was not present in the Fiori Launchpad on this trial project, user permissions was not granted in practice.

**Important distinction:**

The IAM application and Business Catalog are not required to run the UI5 application locally using `npm start`. Local development still requires a working connection to the SAP backend and access to the relevant OData services.

For access through SAP Fiori Launchpad, the Launchpad App Descriptor Item must be connected to the IAM application. The IAM application must then be assigned to a Business Catalog, which can be assigned to a Business Role and subsequently to a business user.

The creation and assignment of Business Roles, as well as the full Launchpad access configuration, are dependent on the available SAP administration applications and user permissions.

## 8. Applications and Usage

The project contains one custom UI5 application and additional backend services that can be accessed through their OData V4 service bindings.

### 8.1 Webshop – Custom UI5

**Application:** `ZSPAC103_SHOP`

**Service binding:** `ZUI_SPAC103_PRODUCT_Q_O4`

The webshop is the main user-facing application.

It combines Fiori Elements and custom SAPUI5 functionality.

#### Product Catalog

The product catalog provides an overview of the available products.

Users can:

- Browse products.
- View product images and descriptions.
- Filter products by currency.
- View product prices in the selected currency.
- Open product details.

The currently supported example currencies are DKK and EUR.

#### Shopping Cart

Users can open the Shopping Cart overview from the product catalog.

The application supports:

- Viewing existing shopping carts.
- Opening individual shopping carts.
- Adding products to a cart.
- Changing product quantities.
- Viewing unit prices and calculated totals.
- Checking out an open shopping cart.

When a user adds a product, the application looks for an existing open shopping cart belonging to that user and using the selected currency.

If no matching cart exists, a new one is created.

If the product is already present in the cart, its quantity is increased rather than creating another line.

The system automatically calculates item totals and the overall cart total.

#### Checkout

Checkout performs inventory validation and stock allocation.

The system:

1. Checks that the cart is open and contains products.
2. Checks the requested quantities.
3. Reads the available stock across the warehouses.
4. Verifies that sufficient stock exists for every product.
5. Allocates the requested quantities across the available warehouses.
6. Updates the stock quantities.
7. Marks the shopping cart as completed.

If there is insufficient stock for any product, checkout is rejected and the stock is not modified.

Checkout does not include payment processing or external order fulfilment.

### 8.2 Product, Price, Stock and Warehouse Management

**Service binding:** `ZUI_SPAC103_STOCK_O4`

This service exposes four entities:

| Entity | Available functionality |
|---|---|
| Product | Create, edit and delete products. |
| Product Price | Create prices through the product relationship, edit prices and delete price entries. |
| Stock | Create, edit and delete stock entries. |
| Warehouse | Create, edit and delete warehouses. |

The service can be accessed through its Fiori Elements preview in ADT by opening the corresponding Service Binding.

These are backend management interfaces generated from the RAP and CDS metadata. They are not separate custom UI5 applications included in the repository.

**Product management** includes product details such as name, description and image, with related product prices.

**Stock management** allows stock quantities to be maintained for individual products at specific warehouses.

**Warehouse management** maintains warehouse names, addresses, ZIP codes and cities.

### 8.3 Unused Product Catalog Service

**Service binding:** `ZUI_SPAC103_PRODUCT_CAT_O4`

This service binding belongs to an earlier product catalog implementation.

It is retained in the repository but is **not used by the current webshop**.

The earlier implementation had difficulties with setting a default value for the currency field in the product catalog interface.

The current webshop instead uses:

```text
ZUI_SPAC103_PRODUCT_Q_O4
```

This service exposes the product catalog, value help and shopping cart entities required by the current custom UI5 application.

Use the Product Query service for the webshop rather than the unused Product Catalog service.

## 9. OData Services

Overview of the project's service bindings:

| Service Binding | Service Definition | Purpose |
|---|---|---|
| `ZUI_SPAC103_PRODUCT_Q_O4` | `ZUI_SPAC103_PRODUCT_Q_SD` | Webshop product catalog and shopping cart |
| `ZUI_SPAC103_STOCK_O4` | `ZUI_SPAC103_STOCK_O4` | Product, price, stock and warehouse management |
| `ZUI_SPAC103_PRODUCT_CAT_O4` | `ZUI_SPAC103_PRODUCT_CAT_SD` | Earlier product catalog implementation; not in use |

All three bindings use OData V4. The first two are the services used by the current solution.

## 10. Known Limitations

- Payment processing is not implemented.
- Checkout demonstrates inventory validation and allocation rather than a complete order fulfilment process.
- The project uses example data and is intended for development and demonstration.
- Authorization and validation are not yet comprehensive enough for a production webshop.
- The `ZUI_SPAC103_PRODUCT_CAT_O4` service binding is not used by the current webshop.
- The frontend depends on a correctly configured and accessible SAP backend.

## 11. Future Improvements

- **Expanded validation and authorization:** Improve data validation, business rules and user access control across the application.
- **Automated testing:** Introduce automated tests for RAP Business Objects, determinations, validations, actions and other business logic.

## 12. License and Usage

This is a learning and demonstration project.

The repository is intended to document the implementation and provide an example of SAP ABAP Cloud, RAP, CDS, OData V4 and SAPUI5 development.
