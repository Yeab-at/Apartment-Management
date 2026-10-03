# Apartment Management Database

A PostgreSQL database system for managing an apartment building, including tenants, rooms, payments, staff, maintenance requests, and lease management.

## Tools Used
* **PostgreSQL:** Database design, data storage, functions, procedures, triggers and granting roles

## Database Tables

### Department
Stores Department informations:
* Department Id
* Department name

### Staff
Stores information about staff that use the database, including:
* Staff name
* Phone number
* Email
* Staff ID

### Room Type
Stores specific information of the room, including:
* Bedrooms
* Cost
* Size
* Description
* Room type ID

### Room
Stores surface level information of the room, including:
* Room availability
* Floor number
* Room type Id
* Room Id

### Tenant
Stores information about tenant, including:
* Tenant name
* Phone number
* Email
* Tenant ID

### Tenant Room
Stores information about rooms connected to a tenant, including:
* Room number
* Occupancy start date
* Occupancy end date
* Tenant ID

### Payment Agreement
Stores payment information for an event using the event ID, including:
* Payment date
* Room number
* Room cost
* Agreement date
* Tenant Id
* Agreement Id

### Payment
Stores payment information for an event using the event ID, including:
* Payment amount
* Payment done date
* Payment status
* Payment late status
* Agreement Id
* Payment Id

### Maintenance
Stores information about a maintenance request, including:
* Room number
* Issue
* request date
* Maintenance status
* Request Id

 ### Tenant Staff
Stores information of maintenance dealings, including:
* Room number
* Assistance Type
* Assistance issue date
* Staff Id
* Issue number

## Database Functions and Procedures
The database uses stored procedures and functions to handle operations, including:
* Adding departments, staff, tenants, rooms, and room types
* Assigning tenants to rooms
* Processing payments
* Checking overdue payments
* Creating maintenance requests
* Assigning staff assistance to tenants
* Cancelling leases
* Ending leases

## Triggers 
The database records operations such as INSERT, UPDATE, and DELETE along with the date, time, and database user on every table.

## Grants
The database has different user roles with their own password, with each role having access to the procedures and information they need.

HR Member: manages departments and staff, including adding department information and staff details.

Maintenance Member : handles maintenance requests and record staff assistance given to tenants.

Receptionist: manages tenant information, assign tenants to rooms, and handle lease cancellations.

Finance: process tenant payments.


## ER Diagram
<img width="1197" height="796" alt="image" src="https://github.com/user-attachments/assets/be1278c8-0b49-4026-a3c4-b267417e4bd4" />
<img width="1101" height="653" alt="image" src="https://github.com/user-attachments/assets/14ca0aba-3b5a-42bc-a8d5-dd95c8e5b1f3" />

