#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Parse the primitive usage figures from a Xilinx Vivado report
that has been generated like this:
    foreach {i} [ get_cells ] { report_utilization -cells $i -file cell_${i}_util.txt }
"""

from __future__ import print_function
import pathlib
import glob
import re
import pandas as pd

debug = False


def debug_print(message):
    if debug == True:
        print(message)


def read_table(lines, section, index):
    """
    Parse an ASCII table to extract the values in it.
    The table looks like this:
        +-------------------------+------+-------+-----------+-------+
        |        Site Type        | Used | Fixed | Available | Util% |
        +-------------------------+------+-------+-----------+-------+
        | Slice LUTs              |   27 |     0 |     46200 |  0.06 |
        |   LUT as Logic          |   27 |     0 |     46200 |  0.06 |
        |   LUT as Memory         |    0 |     0 |     14400 |  0.00 |
        | Slice Registers         |   13 |     0 |     92400 |  0.01 |
        |   Register as Flip Flop |   13 |     0 |     92400 |  0.01 |
        |   Register as Latch     |    0 |     0 |     92400 |  0.00 |
        | F7 Muxes                |    0 |     0 |     23100 |  0.00 |
        | F8 Muxes                |    0 |     0 |     11550 |  0.00 |
        +-------------------------+------+-------+-----------+-------+

    or this (2024.2+):
        +----------+------+---------------------+
        | Ref Name | Used | Functional Category |
        +----------+------+---------------------+
        | LUT6     |   13 |                 LUT |
        | FDRE     |   13 |        Flop & Latch |
        | LUT1     |   11 |                 LUT |
        | LUT4     |    3 |                 LUT |
        | CARRY4   |    3 |          CarryLogic |
        +----------+------+---------------------+

    If the first character of the "index" input is not a '+', then this is
    not a valid table and we return an empty result.

    Present the results as a list.
    """
    table_content = []
    original_index = index

    # A table starts with a '+' chracter
    # If we don't get one, then this is not a table and we
    # return an empty list.
    line = lines[index].strip()
    if len(line) != 0:
        if line[0] != "+":
            # Not a table, so return an empty list
            return (table_content, original_index)
    else:
        # Not a table, so return an empty list
        return (table_content, original_index)

    # Now, extract the header names and remove the whitespace surrounding them
    headers_valid = False
    index = index + 1
    line = lines[index].strip()
    headers = [s.strip() for s in line[1:-1].split("|")]
    # The headers that we care about are:
    #   Either "Site Type" or "Ref Name" for the name of the resource
    # or
    #   "Used" for the number of resources used
    if "Site Type" in headers:
        headers_valid = True
        type_index = headers.index("Site Type")
        used_index = headers.index("Used")
    if "Ref Name" in headers:
        headers_valid = True
        type_index = headers.index("Ref Name")
        used_index = headers.index("Used")

    # Skip one row
    index = index + 2

    # The table ends if you come across another line starting with '+'
    table = True
    while index < len(lines) and table:
        line = lines[index].strip()
        if len(line) == 0:
            table = False
        else:
            if line[0] == "+":
                table = False
            else:
                if headers_valid:
                    data = [s.strip() for s in line[1:-1].split("|")]
                    # debug_print(section + data[type_index] + ", " + data[used_index])
                    table_content.append([section + data[type_index], data[used_index]])
            index = index + 1

    return (table_content, index)


def parse_cell_tables(lines):
    """
    Find all the tables in a file and send them off to extract useful data.
    """
    all_tables = []

    # Find new sections and extract table data
    i = 0
    while i < len(lines):
        line = lines[i].strip()

        # Parse out specific section titles by looking for lines that
        # look like this "3. Memory"
        # Throw away the number and keep the name: "Memory"
        matches = re.match(r"^([0-9\.]+)\s+(.*)", line)
        if matches:
            # TODO: Add an optional filter for the section
            section_index = matches[1]
            # section_name = matches[2]

            # Check it's not the "Table Of Contents" section by looking
            # for the '+' character that marks the start of a table
            if lines[i + 3][0] == "+":
                (table, i) = read_table(lines, section_index, i + 3)
                # debug_print(table)
                # Add the table if it was recognised
                if len(table) > 0:
                    all_tables.append(table)
        i = i + 1

    flat_list = [item for sublist in all_tables for item in sublist]

    return flat_list


def reshape_all_results(results, filename="cell_usage.csv"):
    """
    Take a data structure like this:
        dictionary of cell names
          list of tables
            list of table entries
    Reshape it into a single Pandas DataFrame
    """
    # We can't assume the resource lists are the same for all nodes
    # because some will use resources that others don't.
    # The solution to this is to use Pandas

    cell_list = list(results.keys())

    # Get the resource names from the first list of table results
    # and turn them into a Pandas DataFrame
    resources = results[cell_list[0]]

    rt1 = [list(x) for x in zip(*resources)]
    rtdf1 = pd.DataFrame([rt1[1]], columns=list(rt1[0]), index=[cell_list[0]])

    # Remove duplicated columns
    rtdf1 = rtdf1.loc[:, ~rtdf1.columns.duplicated()].copy()

    i = 1
    while i < len(cell_list):
        resources = results[cell_list[i]]
        rt2 = [list(x) for x in zip(*resources)]
        rtdf2 = pd.DataFrame([rt2[1]], columns=list(rt2[0]), index=[cell_list[i]])

        # Remove duplicated columns
        rtdf2 = rtdf2.loc[:, ~rtdf2.columns.duplicated()].copy()

        # Merge the two dataframes.
        # The trick here is to put the longest one first,
        # because it will have more columns in it
        if rtdf2.shape[1] > rtdf1.shape[1]:
            rtdf1 = pd.concat([rtdf2, rtdf1], axis=0).fillna(0)
        else:
            rtdf1 = pd.concat([rtdf1, rtdf2], axis=0).fillna(0)

        i = i + 1
    return rtdf1


def main(scan_dir):
    """
    Scan the files in a directory for cell usage reports,
    then parse every value in them and create a file of the results
    """
    results = {}
    # Convert a relative path to an absolute one
    if scan_dir[0] == ".":
        pwd = pathlib.Path.cwd()
        result_path = pwd / scan_dir
    else:
        result_path = pathlib.Path(scan_dir)

    for filename in glob.glob(str(result_path) + "/cell_*_util.txt"):
        file_path = pathlib.Path(filename)
        debug_print("Parsing " + str(file_path))
        file_handle = open(file_path, "r")
        lines = file_handle.readlines()
        file_handle.close()

        # Strip off the "cell_" and the "_util.txt" to get the cell name
        cell_name = file_path.name[5:-9]
        results[cell_name] = parse_cell_tables(lines)

    # Gather all the table results together into a sorted Pandas DataFrame
    all_cells_df = reshape_all_results(results).sort_index(axis=1)

    # Write the results out to a CSV file
    output_filename = result_path / "all_cells_util.csv"
    print("Writing results to: " + str(output_filename))
    all_cells_df.to_csv(str(output_filename))
    output_filename = result_path / "all_cells_util_transposed.csv"
    print("Writing transposed results to: " + str(output_filename))
    all_cells_df.T.to_csv(str(output_filename))


if __name__ == "__main__":
    import sys

    # Crude command-line input handling
    if len(sys.argv) > 1:
        scan_dir = sys.argv[1]
        main(scan_dir)
    else:
        print("Usage: parse_usage.py <directory to scan>")
