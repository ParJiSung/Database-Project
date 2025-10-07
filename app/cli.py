import typer, json, requests

app = typer.Typer()

@app.command()
def menu():
    print(json.dumps(requests.get("http://localhost:5000/menu").json(), indent=2))

@app.command()
def demo_order(customer_id:int=11):
    payload = {
        "customer_id": customer_id,
        "pizzas": [{"id":1,"qty":1},{"id":6,"qty":1}],
        "products": [{"id":3,"qty":1}]
    }
    r = requests.post("http://localhost:5000/orders", json=payload)
    print(r.status_code, r.json())

if __name__ == "__main__":
    app()
