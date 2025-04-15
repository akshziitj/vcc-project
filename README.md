# CHOPT on Google Cloud Platform (GCP) - System Architecture & README

## 📘 Overview
CHOPT (Cloud-based Hyperparameter Optimization Tool) is designed to automate and scale the search for optimal hyperparameters for machine learning models. This document outlines the architecture and deployment of CHOPT on Google Cloud Platform (GCP).

---

## 🏗 System Architecture

### 🔹 1. User Interface
- **Frontend:** Web UI (hosted on App Engine or in GKE)
- **Purpose:** Allows users to submit experiment configurations (YAML/JSON).
- **Security:** IAM or Cloud Identity for authentication

### 🔹 2. API Gateway & Load Balancer
- **Components:** Cloud Load Balancing + API Gateway
- **Purpose:** Accepts incoming requests, performs validation, routes to microservices

### 🔹 3. Control Plane (Experiment Manager)
- **Deployed on:** GKE
- **Orchestration:** Cloud Composer (Airflow DAGs)
- **Function:** Receives user config, splits HPO space, schedules jobs

### 🔹 4. Search Algorithm Service
- **Deployed on:** GKE or Cloud Functions
- **Algorithms:** Grid Search, Random Search, Bayesian Optimization
- **Function:** Selects next parameter set to evaluate

### 🔹 5. Worker Pool (Training Jobs)
- **Execution Engines:** Vertex AI Jobs or GKE Job Pods
- **Function:** Trains models with selected hyperparameters
- **Artifact Storage:** Cloud Storage

### 🔹 6. Messaging and Coordination
- **GCP Services:** Pub/Sub + Cloud Tasks
- **Function:** Async coordination of job status, retries, completion signals

### 🔹 7. Logging & Monitoring
- **Services:** Cloud Logging, Monitoring, Trace
- **Purpose:** Metrics, tracing, system observability

### 🔹 8. Result Storage & Visualization
- **Structured Results:** BigQuery
- **Metadata & Status:** Firestore
- **Checkpoints & Artifacts:** Cloud Storage

---

## 🛠 GCP Infrastructure Setup

### Step 1: Set up Project & Enable Services
```bash
gcloud projects create chopt-project
gcloud config set project chopt-project
gcloud services enable compute.googleapis.com container.googleapis.com \
    composer.googleapis.com pubsub.googleapis.com \
    aiplatform.googleapis.com run.googleapis.com \
    bigquery.googleapis.com firestore.googleapis.com
```

### Step 2: Create GKE Cluster
```bash
gcloud container clusters create chopt-gke \
    --zone us-central1-c --num-nodes=3
```

### Step 3: Deploy Microservices
```bash
kubectl apply -f experiment-manager.yaml
kubectl apply -f search-algorithm.yaml
kubectl apply -f result-tracker.yaml
```

### Step 4: Configure Vertex AI Jobs
```bash
gcloud ai custom-jobs create \
    --display-name="chopt-job" \
    --config=job-config.yaml
```

### Step 5: Set up Cloud Composer
```bash
gcloud composer environments create chopt-orchestrator \
    --location=us-central1 --image-version=composer-2.0.0-airflow-2.2.3
```

### Step 6: Messaging via Pub/Sub
```bash
gcloud pubsub topics create chopt-events
gcloud pubsub subscriptions create chopt-sub --topic=chopt-events
```

### Step 7: Deploy API Gateway
```bash
gcloud api-gateway gateways create chopt-gateway \
    --api=chopt-api --api-config=chopt-config --location=us-central1
```

### Step 8: Logging & Monitoring
```bash
gcloud logging sinks create chopt-logs ...
gcloud monitoring dashboards create --config-from-file=dashboard.json
```

### Step 9: Setup Storage
```bash
bq mk chopt_results
gcloud firestore databases create --region=us-central
gsutil mb gs://chopt-artifacts
```

---

## 🧩 System Design Patterns Used
- Orchestrator Pattern (Cloud Composer)
- Retry with Backoff (Cloud Tasks)
- Observer Pattern (Pub/Sub events)
- CQRS (BigQuery reads, Firestore writes)
- Bulkhead Pattern (worker pool isolation)
- Distributed Tracing (Cloud Trace)

---

## 📈 Monitoring Checklist
- Dashboard: Cloud Monitoring custom metrics (worker status, trial duration)
- Logs: Cloud Logging filters by microservice
- Alerts: Cloud Monitoring alerts on job failures or API rate limits

---

## 📬 Contact
For questions or contributions, please contact the CHOPT GCP maintainers.

