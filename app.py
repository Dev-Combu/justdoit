from flask import Flask, jsonify

app = Flask(__name__)

# Sample data: list of dictionaries representing schedule records
schedules = [
    {'id': 1, 'title': 'Meeting', 'start_time': '2023-10-01T10:00:00Z', 'end_time': '2023-10-01T11:00:00Z'},
    {'id': 2, 'title': 'Lunch', 'start_time': '2023-10-01T12:00:00Z', 'end_time': '2023-10-01T13:00:00Z'}
]

@app.route('/schedules', methods=['GET'])
def get_schedules():
    return jsonify(schedules)

if __name__ == '__main__':
    app.run(debug=True)
