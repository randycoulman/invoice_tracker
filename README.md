# InvoiceTracker

Command-line application for tracking and reporting on invoices and payments.

## Introduction

This was an Elixir learning project for me and is very specific to my needs.  That said, if you think you'd find value in it, you're more than welcome to try it out.

InvoiceTracker is a command-line application that I use to track invoices and payments for my side contract work.  It makes the following assumptions:

- Tracks invoices for a single client.
- A written summary of the work performed for each invoice is required.
- Time entries for invoices are tracked using [Toggl](https://toggl.com/).
- Time is billed in 6-minute increments (tenths of an hour).

The code is designed such that it should be relatively easy to change any of these assumptions should the need arise.

In addition, default option values assume that:
- Invoicing happens twice a month, on the 1st and 16th of the month.
- Invoice payment status is reported weekly every Friday.

You can override the defaults on the command-line.

## Installation

In order to run this application, you will need to have a recent version of Elixir installed (along with Erlang, since Elixir runs on the Erlang VM).  I use [asdf](https://github.com/asdf-vm/asdf) to manage both Erlang and Elixir installation.

After cloning the repository, run `MIX_ENV=prod mix escript.build` to build the application, then copy `invoice` somewhere on your path.

## Usage

The `invoice` application is composed of a number of sub-commands.  The basic usage of `invoice` is:

```
invoice [--file=<data file>] <command> [<args>]
```

InvoiceTracker requires a data file to store the invoice data.  If none is provided, it will use `invoices.ets` in the current working directory.  The data file can also be specified in the `.invoicerc` configuration file (see below).

### `invoice generate`

Generates invoice line items and work summary based on time tracking data retrieved from Toggl.  If you'd rather enter invoices manually instead of generating them, use `invoice record`.

```
invoice generate [options]
```

You can also use `invoice gen` or `invoice g` as short-hand command names.  To generate an invoice using Toggl time-tracking data, you will need some information from your Toggl account:

- API Token: You can find your API token in your Toggl Profile.
- Workspace ID: The easiest way to find your workspace ID is to go to `Manage Workspaces` in Toggl, then view the Settings for the workspace.  The URL bar in your browser will look something like `https://toggl.com/app/workspaces/<ID>/settings`.  The number between `/workspaces/` and `/settings` is the workspace ID.
- Client ID:  This one is harder to find using the Toggl web interface.  One way is to generate a summary report and select the client.  After applying that selection, the URL bar in your browser will be something like `https://toggl.com/app/reports/summary/<workspace ID>/period/thisWeek/clients/<client ID>/billable/both`.

All three of these values can be configured in the `.invoicerc` configuration file.  See below for details.

Options include:
- `--api_token <Toggl API token>` (or `-t <Toggl API token>`): the API token required to retrieve data from Toggl.  You can also specify the API token in the `.invoicerc` configuration file.  See below for details.

- `--workspace_id <Toggl workspace ID>` (or `-w <Toggl workspace ID`): the ID of the Toggl workspace containing the time entries.  You can also specify the workspace ID in the `.invoicerc` configuration file.  See below for details.

- `--client_id <Toggl client ID>` (or `-c <Toggl client ID>`): the ID of the Toggl client being invoiced.  You can also specify the client ID in the `.invoicerc` configuration file.  See below for details.

- `--rate <hourly rate>` (or `-r <hourly rate>`): the hourly rate to charge the client.  You can also specify the hourly rate in the `.invoicerc` configuration file.  See below for details.

- `--number <invoice number>` (or `-n <invoice number>`): the invoice number for the invoice.  If not provided, InvoiceTracker will find the highest invoice number already recorded and use the next highest number.

- `--date <invoice date>` (or `-d <invoice date>`): the date of the invoice in `YYYY-MM-DD` format.  If not provided, InvoiceTracker will use the most recent 1st or 16th of the month.  However, if this command is run on the 15th or last day of the month, it will assume you're recording the next day's invoice instead.

- `--save` (or `-s`): record the generated invoice.  By default, the invoice information will be printed but not recorded.  Once you're satisfied with the invoice contents, re-run the command with the `--save` flag to actually record the invoice.

### `invoice record`

Records an invoice.  Use this command if you want to enter invoices manually instead of generating them from Toggl time-tracking data.  To generate invoices instead, use `invoice generate`.

```
invoice record [options] <amount>
```

You can also use `invoice rec` or `invoice r` as short-hand command names.

Options include:
- `--number <invoice number>` (or `-n <invoice number>`): the invoice number for the invoice.  If not provided, InvoiceTracker will find the highest invoice number already recorded and use the next highest number.

- `--date <invoice date>` (or `-d <invoice date>`): the date of the invoice in `YYYY-MM-DD` format.  If not provided, InvoiceTracker will use the most recent 1st or 16th of the month.  However, if this command is run on the 15th or last day of the month, it will assume you're recording the next day's invoice instead.

### `invoice payment`

Records an invoice payment.  There is no support for partial payments; InvoiceTracker assumes that all invoices are paid in full when they are paid.

```
invoice payment [options]
```

You can also use `invoice pay` or `invoice p` as short-hand command names.

Options include:
- `--number <invoice number>` (or `-n <invoice number>`): the invoice number for the invoice that was paid.  If not provided, InvoiceTracker will assume that the oldest unpaid invoice is the one being paid.

- `--date <invoice date>` (or `-d <invoice date>`): the date of the payment in `YYYY-MM-DD` format.  If not provided, InvoiceTracker will assume that the invoice was paid on day the command was run.

### `invoice list`

Lists recorded invoices.

```
invoice list [options]
```

You can also use `invoice ls` or `invoice l` as short-hand command names.

Options include:
- `--all` (or `-a`): list all recorded invoices.  By default, only unpaid invoices are listed.  To see all invoices instead, use the `--all` option.

### `invoice status`

Generates a weekly invoice status report.

```
invoice status [options]
```

You can also use `invoice stat` or `invoice s` as short-hand command names.

Options include:
- `--date <status date>` (or `-d <status date>`): the date of the status report in `YYYY-MM-DD` format.  If not provided, InvoiceTracker will assume that the report is for the most recent Friday.

- `--since <previous status date>` (or `-s <previous status date>`): the date of the previous status report in `YYYY-MM-DD` format.  The status report will show all activity between the previous status date and status date.  If not provided, InvoiceTracker will use the date 1 week prior to the status date.

## Configuration File

InvoiceTracker reads a configuration from a file named `.invoicerc` in your home directory.  This is a handy place to configure options that don't change very often.  Each line of the configuration is of the form `setting = value`.

Settings provided on the command-line take precedence over those specified in the `.invoicerc` file.

Available settings include:
- `file`: The invoice data file to use; equivalent to the global `--file` option.
- `api_token`: The Toggl API token needed for `invoice generate`.  Equivalent to the `--token` option of the `invoice generate` command.
- `workspace_id`: The Toggl workspace ID needed for `invoice generate`.  Equivalent to the `--workspace_id` option of the `invoice generate` command.
- `client_id`: The Toggl client ID needed for `invoice generate`.  Equivalent to the `--client_id` option of the `invoice generate` command.
- `rate`: The hourly rate needed for `invoice generate`.  Equivalent to the `--rate` option of the `invoice generate` command.

## Development

This is a pretty standard Elixir project.  To work with it:

- Clone the repository
- run `mix deps.get`

You can run the tests with `mix test`.  If you'd like the tests to automatically run every time you make a change, use `mix test.watch`.

If you want to skip the feature tests in order to get quicker turns while developing, you can use `mix test --exclude features` or `mix test.watch --exclude features`.  Make sure to run `mix test` at least once before committing your changes.

The project is configured to use `credo` for linting, and `dialyxir` for type checking.  Run `mix credo` and `mix dialyzer` respectively to run those checks.

A development version of the escript will be built automatically when running the tests because the feature tests run against the actual CLI application.

To build a release version, run `MIX_ENV=prod mix escript.build`.
