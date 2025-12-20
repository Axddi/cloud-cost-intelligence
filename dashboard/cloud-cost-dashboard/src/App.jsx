import { useEffect, useState } from "react";
import "./App.css";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Tooltip,
  Legend,
} from "chart.js";
import { Bar } from "react-chartjs-2";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Tooltip,
  Legend
);

const BASE_API =
  "https://8eo9h9aqdc.execute-api.ap-south-1.amazonaws.com/dev/costs";

function App() {
  const [date, setDate] = useState("2025-12-20");
  const [data, setData] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);
  const [selectedService, setSelectedService] = useState("ALL");

  const filteredData =
    selectedService === "ALL"
      ? data
      : data.filter(item => item.service === selectedService);

  const totalCost = filteredData.reduce(
    (sum, item) => sum + Number(item.cost),
    0
  );

  const chartData = {
    labels: filteredData.map(item => item.service),
    datasets: [
      {
        label: "Cost ($)",
        data: filteredData.map(item => item.cost),
        backgroundColor: "#4f46e5",
        borderRadius: 6,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: { display: false },
    },
    scales: {
      y: {
        beginAtZero: true,
        ticks: {
          callback: value => `$${value}`,
        },
      },
    },
  };

  async function fetchCosts(selectedDate) {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${BASE_API}?date=${selectedDate}`);
      const result = await response.json();
      setData(result);
    } catch {
      setError("Failed to fetch cost data");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchCosts(date);
  }, [date]);

  return (
    <div className="app">
      <div className="dashboard">
        <div className="header">
          <h1>Cloud Cost Dashboard</h1>
          <p className="subtitle">Daily AWS service cost breakdown</p>
        </div>

        <div className="controls">
          <label>
            Date
            <input
              type="date"
              value={date}
              onChange={e => setDate(e.target.value)}
            />
          </label>

                      <div className="service-buttons">
  {["ALL", "Amazon EC2", "Amazon S3"].map(service => (
    <button
      key={service}
      className={selectedService === service ? "active" : ""}
      onClick={() => setSelectedService(service)}
    >
      {service}
    </button>
  ))}
</div>

        </div>

        {loading && <p className="info">Loading cost data...</p>}
        {error && <p className="error">{error}</p>}

        {!loading && filteredData.length > 0 && (
          <div className="insights">
            <div className="total">
              Total Spend <span>${totalCost.toFixed(2)}</span>
            </div>
          </div>
        )}

        {!loading && filteredData.length === 0 && !error && (
          <div className="empty">
            <p>No data for this date</p>
            <span>Try a date with AWS activity</span>
          </div>
        )}

        {!loading && filteredData.length > 0 && (
          <div className="chart">
            <h3>Cost by Service</h3>
            <Bar data={chartData} options={chartOptions} />
          </div>
        )}

        {filteredData.length > 0 && (
          <table>
            <thead>
              <tr>
                <th>Service</th>
                <th>Cost ($)</th>
              </tr>
            </thead>
            <tbody>
              {filteredData.map((item, index) => (
                <tr key={index}>
                  <td>{item.service}</td>
                  <td>${item.cost}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

export default App;
