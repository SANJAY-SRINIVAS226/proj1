# 🚗 Vehicle Insurance MLOps Project

An end-to-end Machine Learning Operations pipeline for vehicle insurance prediction — covering data ingestion from MongoDB Atlas, model training, evaluation, deployment on AWS, and a live prediction API served via FastAPI with CI/CD automation through GitHub Actions.

---

## 📁 Project Structure

```
vehicle-insurance-mlops/
├── src/
│   ├── components/
│   │   ├── data_ingestion.py
│   │   ├── data_validation.py
│   │   ├── data_transformation.py
│   │   └── model_trainer.py
│   ├── configuration/
│   │   ├── mongo_db_connections.py
│   │   └── aws_connection.py
│   ├── data_access/
│   │   └── proj1_data.py
│   ├── entity/
│   │   ├── config_entity.py
│   │   ├── artifact_entity.py
│   │   ├── estimator.py
│   │   └── s3_estimator.py
│   ├── pipeline/
│   │   └── training_pipeline.py
│   ├── aws_storage/
│   ├── utils/
│   │   └── main_utils.py
│   └── constants/
│       └── __init__.py
├── config/
│   └── schema.yaml
├── notebook/
│   ├── EDA.ipynb
│   ├── feature_engineering.ipynb
│   └── mongoDB_demo.ipynb
├── static/
├── templates/
├── .github/
│   └── workflows/
│       └── aws.yaml
├── app.py
├── demo.py
├── template.py
├── setup.py
├── pyproject.toml
├── requirements.txt
├── Dockerfile
├── .dockerignore
└── .gitignore
```

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Language | Python 3.10 |
| Data Store | MongoDB Atlas |
| ML Framework | Scikit-learn |
| API | FastAPI |
| Cloud Storage | AWS S3 |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Deployment | AWS EC2 + ECR |
| Environment | Conda |

---

## ⚙️ Local Setup

### 1. Clone the Repository

```bash
git clone https://github.com/SANJAY-SRINIVAS226/proj1.git
cd proj1
```

### 2. Create & Activate Virtual Environment

```bash
conda create -n vehicle python=3.10 -y
conda activate vehicle
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

Verify local packages are installed:

```bash
pip list
```

### 4. Generate Project Template

```bash
python template.py
```

---

## 🌿 Environment Variables

Set the following environment variables before running the project.

### MongoDB Connection URL

**Bash:**
```bash
export MONGODB_URL="mongodb+srv://<username>:<password>@cluster0.xxxx.mongodb.net/<dbname>?appName=Cluster0"
echo $MONGODB_URL
```

**PowerShell:**
```powershell
$env:MONGODB_URL = "mongodb+srv://<username>:<password>@cluster0.xxxx.mongodb.net/<dbname>?appName=Cluster0"
echo $env:MONGODB_URL
```

### AWS Credentials

**Bash:**
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

**PowerShell:**
```powershell
$env:AWS_ACCESS_KEY_ID="your_access_key"
$env:AWS_SECRET_ACCESS_KEY="your_secret_key"
```

---

## 🍃 MongoDB Atlas Setup

1. Sign up at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new project and a free M0 cluster
3. Create a DB user with username and password
4. Under **Network Access**, add IP `0.0.0.0/0` to allow access from anywhere
5. Get your connection string from **Get Connection String → Drivers → Python 3.6+**
6. Push your dataset to MongoDB using `notebook/mongoDB_demo.ipynb`
7. Verify data in **Database → Browse Collections**

---

## 🔄 ML Pipeline

The training pipeline runs end-to-end through the following stages:

### Stage 1 — Data Ingestion
- Connects to MongoDB Atlas using `mongo_db_connections.py`
- Fetches data in key-value format and transforms it into a DataFrame
- Config: `DataIngestionConfig` | Artifact: `DataIngestionArtifact`

### Stage 2 — Data Validation
- Validates schema against `config/schema.yaml`
- Detects data drift and missing columns
- Config: `DataValidationConfig` | Artifact: `DataValidationArtifact`

### Stage 3 — Data Transformation
- Applies feature engineering and preprocessing pipelines
- Saves transformer object via `estimator.py`
- Config: `DataTransformationConfig` | Artifact: `DataTransformationArtifact`

### Stage 4 — Model Training
- Trains classification model on transformed data
- Evaluates and saves best model
- Config: `ModelTrainerConfig` | Artifact: `ModelTrainerArtifact`

### Stage 5 — Model Evaluation
- Compares new model against the production model stored in S3
- Threshold for model replacement: **2% improvement** (`MODEL_EVALUATION_CHANGED_THRESHOLD_SCORE = 0.02`)

### Stage 6 — Model Pusher
- Pushes the accepted model to AWS S3 bucket `my-model-mlopsproj` under key `model-registry`

### Run the Pipeline

```bash
python demo.py
```

Or trigger training via the API:

```
GET /training
```

---

## ☁️ AWS Setup

### IAM User
1. AWS Console → IAM → Create user (e.g. `firstproj`)
2. Attach **AdministratorAccess** policy
3. Generate Access Keys (CLI type) and download the CSV

### S3 Bucket
1. AWS Console → S3 → Create Bucket
2. Name: `my-model-mlopsproj` | Region: `us-east-1`
3. Uncheck "Block all public access" and acknowledge

### ECR Repository
1. AWS Console → ECR → Create Repository
2. Name: `vehicleproj` | Region: `us-east-1`
3. Copy and save the repository URI

---

## 🐳 Docker

### Build Image

```bash
docker build -t vehicleproj .
```

### Run Container

```bash
docker run -p 5080:5080 \
  -e MONGODB_URL=$MONGODB_URL \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  vehicleproj
```

---

## 🚀 CI/CD with GitHub Actions + AWS EC2

### EC2 Instance Setup

1. Launch an **Ubuntu Server 24.04** EC2 instance (`t2.medium`, 30GB storage)
2. Allow HTTP/HTTPS traffic and open port **5080** in Security Groups
3. SSH into the instance and install Docker:

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
newgrp docker
```

### Self-Hosted GitHub Runner

1. GitHub → Settings → Actions → Runners → New self-hosted runner → Linux
2. Run all **Download** commands on EC2, then configure:

```bash
./config.sh --url https://github.com/<username>/<repo> --token <TOKEN>
# Hit Enter for group, set runner name to: self-hosted
```

3. Install as a persistent background service:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
```

4. Enable auto-start on reboot:

```bash
sudo systemctl enable actions.runner.<runner-name>.service
```

### GitHub Secrets

Add the following secrets under **Settings → Secrets and Variables → Actions**:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key |
| `AWS_DEFAULT_REGION` | `us-east-1` |
| `ECR_REPO` | ECR repository URI |

Every push to `main` triggers the CI/CD pipeline automatically.

---

## 🌐 Running the Application

Once deployed, access the app at:

```
http://<EC2-PUBLIC-IP>:5080
```

Trigger model training via:

```
http://<EC2-PUBLIC-IP>:5080/training
```

---

## 📦 Package Configuration

This project uses `pyproject.toml` for modern Python packaging alongside a minimal `setup.py`. Dependencies are dynamically pulled from `requirements.txt`:

```toml
[tool.setuptools.dynamic]
dependencies = {file = "requirements.txt"}
```

---

## 📓 Notebooks

| Notebook | Purpose |
|---|---|
| `mongoDB_demo.ipynb` | Push dataset to MongoDB Atlas |
| `EDA.ipynb` | Exploratory Data Analysis |
| `feature_engineering.ipynb` | Feature engineering experiments |

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is licensed under the MIT License.