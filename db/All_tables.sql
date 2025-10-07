-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: projectpizza
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `idCustomer` int NOT NULL AUTO_INCREMENT,
  `last_name` varchar(45) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `birthdate` date NOT NULL DEFAULT '2000-01-01',
  `postcode` varchar(45) NOT NULL,
  `city` varchar(45) NOT NULL,
  `street` varchar(45) NOT NULL,
  `number` varchar(45) NOT NULL,
  `createdat` date NOT NULL DEFAULT '2000-01-01',
  PRIMARY KEY (`idCustomer`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (1,'Nicusor','Dan','2000-01-01','','','','','2000-01-01'),(2,'Ragnar','Lothbrok','2000-01-01','','','','','2000-01-01'),(3,'Django','Unchained','2000-01-01','','','','','2000-01-01'),(4,'Leonardo','Dicaprio','2000-01-01','','','','','2000-01-01'),(5,'Dead','Pool','2000-01-01','','','','','2000-01-01'),(6,'Carlos','Prates','2000-01-01','','','','','2000-01-01'),(7,'Alex','Bodi','2000-01-01','','','','','2000-01-01'),(8,'Marcus','Piso','2000-01-01','','','','','2000-01-01'),(9,'Ana','Costache','2000-01-01','','','','','2000-01-01'),(10,'Hunter','Morgan','2000-01-01','','','','','2000-01-01');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_area`
--

DROP TABLE IF EXISTS `delivery_area`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_area` (
  `idemployee` int NOT NULL,
  `postal_code` varchar(45) NOT NULL,
  PRIMARY KEY (`idemployee`,`postal_code`),
  CONSTRAINT `idemployee` FOREIGN KEY (`idemployee`) REFERENCES `employee` (`idEmployee`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_area`
--

LOCK TABLES `delivery_area` WRITE;
/*!40000 ALTER TABLE `delivery_area` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_area` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_unavailable`
--

DROP TABLE IF EXISTS `delivery_unavailable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_unavailable` (
  `idemployee` int NOT NULL,
  `start_time` timestamp NOT NULL,
  `end_time` timestamp NOT NULL,
  PRIMARY KEY (`idemployee`,`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_unavailable`
--

LOCK TABLES `delivery_unavailable` WRITE;
/*!40000 ALTER TABLE `delivery_unavailable` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_unavailable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discount`
--

DROP TABLE IF EXISTS `discount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discount` (
  `discount_code` int NOT NULL,
  `typediscount` varchar(45) NOT NULL,
  `percent` int NOT NULL DEFAULT '0',
  `fixed_discount` int NOT NULL DEFAULT '0',
  `free_product` int DEFAULT NULL,
  `free_pizza` int DEFAULT NULL,
  `is_redeemed` tinyint(1) NOT NULL,
  `reedemedby` int DEFAULT NULL,
  PRIMARY KEY (`discount_code`),
  KEY `product_idx` (`free_product`),
  KEY `pizza_idx` (`free_pizza`),
  KEY `customer_idx` (`reedemedby`),
  CONSTRAINT `customer` FOREIGN KEY (`reedemedby`) REFERENCES `customer` (`idCustomer`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pizza` FOREIGN KEY (`free_pizza`) REFERENCES `pizza` (`idPizza`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `product` FOREIGN KEY (`free_product`) REFERENCES `product` (`idproduct`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discount`
--

LOCK TABLES `discount` WRITE;
/*!40000 ALTER TABLE `discount` DISABLE KEYS */;
/*!40000 ALTER TABLE `discount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `idEmployee` int NOT NULL AUTO_INCREMENT,
  `last_name` varchar(45) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `salary` int NOT NULL,
  `start_date` datetime NOT NULL,
  `available` tinyint(1) NOT NULL,
  `phone` int NOT NULL,
  PRIMARY KEY (`idEmployee`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'John','Smith',1000,'2025-09-04 00:00:00',0,0),(2,'George','Becali',1000,'2025-09-04 00:00:00',0,0),(3,'Bryan','Battle',1250,'2025-09-04 00:00:00',0,0);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `idIngredients` int NOT NULL AUTO_INCREMENT,
  `name_ing` varchar(20) NOT NULL,
  `category` varchar(45) NOT NULL,
  `alergen` tinyint NOT NULL DEFAULT '0',
  `vegetarian` tinyint(1) NOT NULL DEFAULT '0',
  `vegan` tinyint NOT NULL DEFAULT '0',
  `unit` varchar(45) NOT NULL,
  `unit_cost` decimal(5,2) NOT NULL,
  PRIMARY KEY (`idIngredients`),
  UNIQUE KEY `idIngredients_UNIQUE` (`idIngredients`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_pizza`
--

DROP TABLE IF EXISTS `order_pizza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_pizza` (
  `idorder` int NOT NULL,
  `idpizza` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`idorder`,`idpizza`),
  KEY `fk_orderpizza_pizza` (`idpizza`),
  CONSTRAINT `fk_orderpizza_order` FOREIGN KEY (`idorder`) REFERENCES `orders` (`idorder`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orderpizza_pizza` FOREIGN KEY (`idpizza`) REFERENCES `pizza` (`idPizza`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_pizza`
--

LOCK TABLES `order_pizza` WRITE;
/*!40000 ALTER TABLE `order_pizza` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_pizza` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_product`
--

DROP TABLE IF EXISTS `order_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_product` (
  `idorder` int NOT NULL,
  `idproduct` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`idorder`,`idproduct`),
  CONSTRAINT `fk_orderproduct_order` FOREIGN KEY (`idorder`) REFERENCES `orders` (`idorder`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orderproduct_product` FOREIGN KEY (`idorder`) REFERENCES `product` (`idproduct`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_product`
--

LOCK TABLES `order_product` WRITE;
/*!40000 ALTER TABLE `order_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `idorder` int NOT NULL,
  `idcustomer` int NOT NULL,
  `idemployee` int NOT NULL,
  `order_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(45) NOT NULL DEFAULT 'pending',
  `street` varchar(45) NOT NULL,
  `city` varchar(45) NOT NULL,
  `number` varchar(45) NOT NULL,
  `assignedat` varchar(45) DEFAULT NULL,
  `deliveredat` varchar(45) DEFAULT NULL,
  `cancelledat` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idorder`),
  KEY `idcustomer_idx` (`idcustomer`) /*!80000 INVISIBLE */,
  KEY `idEmployeeFK_idx` (`idemployee`),
  CONSTRAINT `idcustomer` FOREIGN KEY (`idcustomer`) REFERENCES `customer` (`idCustomer`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `idEmployeeFK` FOREIGN KEY (`idemployee`) REFERENCES `employee` (`idEmployee`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza`
--

DROP TABLE IF EXISTS `pizza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizza` (
  `idPizza` int NOT NULL AUTO_INCREMENT,
  `pizza_name` varchar(45) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`idPizza`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza`
--

LOCK TABLES `pizza` WRITE;
/*!40000 ALTER TABLE `pizza` DISABLE KEYS */;
INSERT INTO `pizza` VALUES (1,'Margherita',0),(2,'Diavola',0),(3,'Quattro Formagi',0),(4,'Pepperoni',0),(5,'BBQ Chicken',0),(6,'Vegeterian',0),(7,'Capricciosa',0);
/*!40000 ALTER TABLE `pizza` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_ingredients`
--

DROP TABLE IF EXISTS `pizza_ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizza_ingredients` (
  `idPizza` int NOT NULL,
  `idIngredients` int NOT NULL,
  `quantity` decimal(3,2) NOT NULL,
  PRIMARY KEY (`idPizza`,`idIngredients`),
  KEY `idIngredients` (`idIngredients`),
  CONSTRAINT `idIngredients` FOREIGN KEY (`idIngredients`) REFERENCES `ingredients` (`idIngredients`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `idPizza` FOREIGN KEY (`idPizza`) REFERENCES `pizza` (`idPizza`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_ingredients`
--

LOCK TABLES `pizza_ingredients` WRITE;
/*!40000 ALTER TABLE `pizza_ingredients` DISABLE KEYS */;
/*!40000 ALTER TABLE `pizza_ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pricing_policy`
--

DROP TABLE IF EXISTS `pricing_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pricing_policy` (
  `idPrice` int NOT NULL AUTO_INCREMENT,
  `margin` decimal(5,2) NOT NULL,
  `vat` decimal(5,2) NOT NULL,
  `from` date NOT NULL,
  `to` date DEFAULT NULL,
  `ingredient` int NOT NULL,
  PRIMARY KEY (`idPrice`),
  KEY `ingredientsidd_idx` (`ingredient`),
  KEY `idingredients_idx` (`ingredient`),
  KEY `ingrediente_idx` (`ingredient`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pricing_policy`
--

LOCK TABLES `pricing_policy` WRITE;
/*!40000 ALTER TABLE `pricing_policy` DISABLE KEYS */;
INSERT INTO `pricing_policy` VALUES (1,40.00,9.00,'2025-09-04',NULL,0);
/*!40000 ALTER TABLE `pricing_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `idproduct` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `category` tinyint NOT NULL,
  `is_active` varchar(45) NOT NULL,
  PRIMARY KEY (`idproduct`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-19 17:19:16
