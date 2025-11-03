const express = require('express');
const app = express();
const port = process.env.PORT || 80;

app.get('/', (req, res) => {
  res.send('Hello from Krupashni on Azure CI/CD Pipeline!');
});

app.listen(port, () => console.log(`App running on port ${port}`));
//test