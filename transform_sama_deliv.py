# Flatten annotation delivery files from Samasource
# csv files are delivered with all annotation (bboxes, tag) compressed into
# a single "output" field. This script parses those objects into rows
# such that each bbox has its own row with a repeating image name

# standard library
import argparse
import csv
import json
from operator import lt, gt
import os
# define outside references and constants for convenient
# script customization
ROOT_DIR = os.path.abspath(os.path.dirname(__file__))
INPUT_FILENAME = 'all_labels3.csv'
OUTPUT_FILENAME = 'all_labels3_flatten.csv'
INPUT_PATH = os.path.join(ROOT_DIR, INPUT_FILENAME)
OUTPUT_PATH = os.path.join(ROOT_DIR, OUTPUT_FILENAME)


def extract_points(points):
    """
    Takes a list of point pairs and determines xmin, ymin, xmax, ymax
    independent of input order.
    """
    ret = {}
    compare = (
        ('xmin', gt, 0), ('xmax', lt, 0), ('ymin', gt, 1), ('ymax', lt, 1))
    ret['xmin'], ret['ymin'], ret['xmax'], ret['ymax'] = tuple(
        points[0] + points[0])
    for point in points[1:]:
        for item in compare:
            if item[1](ret[item[0]], point[item[2]]):
                ret[item[0]] = point[item[2]]
    return ret


def format_item(item):
    ret = {'bbox_id': item['index'], 'label_name': item['tags']['Object']}
    ret.update(extract_points(item['points']))
    return ret


def row_generator(path):
    with open(path) as input_file:
        reader = csv.DictReader(input_file, delimiter=',')
        for row in reader:
            outputs = json.loads(row['Output'])
            for item in outputs:
                formatted_item = {
                    'task_id': row['task_id'], 'name': row['name'],
                    'url': row['url']}
                formatted_item.update(format_item(item))
                yield formatted_item


def new_generator(path):
    with open(path) as input_file:
        reader = csv.DictReader(input_file, delimiter=',')
        for row in reader:
            annotations = json.loads(row['Annotation'])
            for record in annotations['layers']['vector_tagging']:
                for item in record['shapes']:
                    formatted_item = {
                        'task_id': row['task_id'], 'name': row['name'],
                        'url': row['url']}
                    formatted_item.update(format_item(item))
                    yield formatted_item


def convert(input_file_path, output_file_path, generator=row_generator):
    with open(output_file_path, 'w') as output_file:
        fieldnames = [
            'task_id', 'name', 'url', 'bbox_id', 'xmin', 'xmax', 'ymin',
            'ymax', 'label_name']
        writer = csv.DictWriter(output_file, fieldnames=fieldnames)
        writer.writeheader()
        for row in generator(input_file_path):
            writer.writerow(row)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-i', '--input', help='Input file', type=str, default=INPUT_PATH)
    parser.add_argument(
        '-o', '--output', help='Output file', type=str, default=None)
    parser.add_argument(
        '-g', '--new_generator', help='Use newer schema', action='store_true')
    args = parser.parse_args()
    input_path = os.path.abspath(args.input)
    output_path = os.path.abspath(
        args.output or args.input.replace('.csv', '_flatten.csv'))
    if not args.new_generator:
        convert(input_path, output_path)
    else:
        convert(input_path, output_path, generator=new_generator)


if __name__ == '__main__':
    main()
