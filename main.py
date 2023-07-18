from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/popup', methods=['POST'])
def popup():
    name = request.form['name']
    return jsonify({'name': name})

@app.route('/get_message', methods=['POST'])
def get_message():
    name = request.form['name']
    message = hashWithKeccak(name)
    return jsonify({'message': message})

def hashWithKeccak(name):
    # TODO: connect to contract and hash name with keccak
    name = name + "iuv"
    return f"Tebrikler {name}"

if __name__ == '__main__':
    app.run(debug=True)
