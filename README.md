**Azure Event-Driven CSV Ingestion Pipeline with Copilot Integration**
 ________________________________________________________
 
 **Overview**

This project demonstrates an end-to-end event-driven data ingestion pipeline in Azure.
When a CSV file is uploaded to Azure Blob Storage, it automatically:

Triggers an Event Grid event

Starts a Logic App Standard workflow

Reads the CSV file

Extracts metadata (file name, row count, event time)

Sends the processed result to an Azure Storage Queue

A second Logic App exposes an HTTP API endpoint that returns the latest processed message.
This endpoint can be used by Microsoft Copilot Studio, Custom Copilot, or any application that wants to query the latest CSV ingestion result.

_________________
**Architecture**

CSV Upload → Event Grid → Logic App (Ingest) → Storage Queue → Logic App (API) → Copilot / Client App

**Features**

✔ Event-driven architecture

Automatically reacts when a new CSV file is uploaded.

✔ Serverless processing

Fully implemented using Logic App Standard (workflow-based automation).

✔ CSV parsing

Counts rows by reading the file content and splitting lines.

✔ Queue-based communication

Processed results are stored in Azure Storage Queue.

✔ REST API for Copilot

Provides an endpoint returning the latest file’s metadata.

✔ Fully cloud-native

Zero servers, fully scalable.

____________

**Technologies Used**


Azure Blob Storage

Azure Event Grid

Azure Logic App Standard

Azure Storage Queue

JavaScript inline code

HTTP-triggered API Logic App

Copilot-compatible REST endpoint

_________

**Step-by-Step Implementation**


Create Storage Resources

1. Create a Storage Account

Enable:

Blob Storage
Queue Storage

2. Create a Blob Container

Name:
incoming

3.Create a Queue

Name:
outqueue

____________
**Configure Event Grid**


We want Event Grid to trigger a Logic App when a file is uploaded.

Create an Event Subscription:

Event type: Blob Created

Source: Your Storage Account

Endpoint Type: Logic App Standard – Workflow Endpoint

Select workflow: ingest_on_blob_eg

This workflow will receive event metadata including:

blob URL
event time
file path
and more.
____________

**Create Logic App Standard: ingest_on_blob_eg**
This workflow processes the CSV file.

Steps:
 **Step 1 — Trigger**

Trigger: When a resource event occurs
(Event Grid → Logic App)

** Step 2 — Compose (extract blob path)**
We use:

triggerBody()?['subject']

Example:
/blobServices/default/containers/incoming/blobs/myfile.csv


**Step 3 — ComposeBlobPath**

Extract the actual path:
replace(outputs('Compose'), '/blobServices/default/containers/', '')


** Step 4 — Get blob content (V2)**

Storage account: your storage account
Blob path: ComposeBlobPath output

This retrieves the CSV file contents.

**Step 5 — ComposeCsv**

Input:
@{body('Get_blob_content_(V2)')}


**Step 6 — ComposeLines**

Split CSV into individual lines:
@split(outputs('ComposeCsv'), '\n')


**Step 7 — ComposeRowCount**

Count data rows (excluding header):
@sub(length(outputs('ComposeLines')), 1)


**Step 8 — Add Message to Queue**

Queue: outqueue
Message:
{
  "fileName": "@{triggerBody()?['data']?['url']}",
  "rows": "@{outputs('ComposeRowCount')}",
  "eventTime": "@{triggerBody()?['eventTime']}"
}

___________________
**Build API Logic App: copilot_get_latest**

This serves as a REST API for Copilot.

**Step 1 — Trigger**
When an HTTP request is received
(You may choose GET or POST — GET works fine for browser testing.)


**Step 2 — Get Messages**

From storage queue outqueue.
Retrieves latest messages.


**Step 3 — For each message → Compose Message**

Input:
@item()?['content']

This extracts the JSON string from each queue message.


**Step 4 — Response**

Status code:

200
Body:
@outputs('Compose_Message')
________________

**Test Output**

When opening the API URL in browser you get:
[
  "{\n  \"fileName\": \"https://.../incoming/test.csv\",\n  \"rows\": \"3\",\n  \"eventTime\": \"2025-11-17T10:49:46Z\"\n}"
]

______________
**Connect to Microsoft Copilot (Optional)**

In Copilot Studio:

Create a Custom Connector

Use your Logic App API endpoint

Add action: “Get latest CSV ingestion result”

Copilot can now answer questions like:

“How many rows did the last uploaded CSV contain?”

____________________
**Final Result**

You now have:

✔ Automated event-driven CSV ingestion

✔ File processing & row counting

✔ Queue-based messaging

✔ A working REST API

✔ Copilot-ready integration

✔ Fully serverless Azure architecture












