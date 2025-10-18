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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (1,'Nicusor','Dan','2000-01-01','1011AB','Amsterdam','Damrak','14','2025-08-01'),(2,'Ragnar','Lothbrok','2000-01-01','1012AC','Amsterdam','Kloveniersburgwal','21','2025-08-02'),(3,'Django','Unchained','2000-01-01','1012AB','Amsterdam','Oudezijds Voorburgwal','3','2025-08-03'),(4,'Leonardo','Dicaprio','2000-01-01','1012AW','Amsterdam','Nieuwezijds Voorburgwal','88','2025-08-04'),(5,'Dead','Pool','2000-01-01','1017DC','Amsterdam','Utrechtsestraat','52','2025-08-05'),(6,'Carlos','Prates','2000-01-01','1016GV','Amsterdam','Prinsengracht','241','2025-08-06'),(7,'Alex','Bodi','2000-01-01','1016CJ','Amsterdam','Keizersgracht','602','2025-08-07'),(8,'Marcus','Piso','2000-01-01','1015DT','Amsterdam','Brouwersgracht','19','2025-08-08'),(9,'Ana','Costache','2000-01-01','1013AA','Amsterdam','Haarlemmerweg','7','2025-08-09'),(10,'Hunter','Morgan','2000-01-01','1019BR','Amsterdam','Piet Heinkade','3B','2025-08-10'),(11,'Jansen','Sophie','1994-03-12','6211 LE','Maastricht','Vrijthof','1','2025-09-05'),(12,'de Vries','Lars','1988-11-02','6211 SZ','Maastricht','Grote Gracht','90','2025-09-06'),(13,'Peeters','Amber','1999-07-21','6211 LM','Maastricht','Tongersestraat','53','2025-09-06'),(14,'Smits','Daan','1992-01-18','6211 PB','Maastricht','Brusselsestraat','45','2025-09-07'),(15,'Brouwers','Emma','1985-05-09','6211 AS','Maastricht','Boschstraat','5','2025-09-07'),(16,'Hendriks','Noah','2001-10-14','6211 EN','Maastricht','Kesselskade','43','2025-09-08'),(17,'Smeets','Liv','1996-12-27','6221 ED','Maastricht','Wycker Brugstraat','24','2025-09-08'),(18,'Maas','Finn','1990-06-30','6211 JP','Maastricht','Sint Pieterstraat','12','2025-09-09'),(19,'van Dijk','Julia','1998-09-05','6221 EJ','Maastricht','Rechtstraat','78','2025-09-10'),(20,'Kosters','Milan','2000-04-03','6221 AV','Maastricht','Heugemerstraat','127','2025-09-11');
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
INSERT INTO `delivery_area` VALUES (1,'6211 LE'),(1,'6211 LM'),(1,'6211 SZ'),(2,'6221 AV'),(2,'6221 ED'),(2,'6221 EJ'),(3,'6211 AS'),(3,'6211 EN'),(3,'6211 PB');
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
  PRIMARY KEY (`idemployee`,`start_time`),
  CONSTRAINT `idemployeeav` FOREIGN KEY (`idemployee`) REFERENCES `employee` (`idEmployee`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_unavailable`
--

LOCK TABLES `delivery_unavailable` WRITE;
/*!40000 ALTER TABLE `delivery_unavailable` DISABLE KEYS */;
INSERT INTO `delivery_unavailable` VALUES (1,'2025-09-21 08:00:00','2025-09-21 10:00:00'),(1,'2025-09-22 16:00:00','2025-09-22 18:00:00'),(2,'2025-09-21 12:00:00','2025-09-21 14:00:00'),(2,'2025-09-23 17:00:00','2025-09-23 20:00:00'),(3,'2025-09-22 07:00:00','2025-09-22 09:00:00'),(3,'2025-09-24 16:00:00','2025-09-24 19:00:00');
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
  `percent` int NOT NULL DEFAULT '0',
  `free_product` int DEFAULT NULL,
  `free_pizza` int DEFAULT NULL,
  `is_redeemed` tinyint(1) NOT NULL,
  `reedemedby` int NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
INSERT INTO `ingredients` VALUES (1,'Mozzarella','Cheese',1,1,0,'gram',0.05),(2,'Tomato Sauce','Sauce',0,1,1,'ml',0.02),(3,'Pepperoni','Meat',0,0,0,'gram',0.06),(4,'Ham','Meat',0,0,0,'gram',0.05),(5,'Mushrooms','Vegetable',0,1,1,'gram',0.03),(6,'Onions','Vegetable',0,1,1,'gram',0.02),(7,'Bell Peppers','Vegetable',0,1,1,'gram',0.03),(8,'Olives','Vegetable',0,1,1,'gram',0.04),(9,'Chicken','Meat',0,0,0,'gram',0.07),(10,'Parmesan','Cheese',1,1,0,'gram',0.06),(11,'Basil','Herb',0,1,1,'gram',0.02),(12,'BBQ Sauce','Sauce',0,1,1,'ml',0.03),(13,'Pineapple','Fruit',0,1,1,'gram',0.04),(14,'Tuna','Fish',1,0,0,'gram',0.08);
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!50001 DROP VIEW IF EXISTS `menu`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `menu` AS SELECT 
 1 AS `Items`,
 1 AS `Price`*/;
SET character_set_client = @saved_cs_client;

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
INSERT INTO `orders` VALUES (1001,1,1,'2025-09-20 18:30:00','delivered','Vrijthof','Maastricht','1','2025-09-20 18:35:00','2025-09-20 19:00:00',NULL),(1002,2,2,'2025-09-20 19:15:00','delivered','Grote Gracht','Maastricht','90','2025-09-20 19:20:00','2025-09-20 19:50:00',NULL),(1003,3,3,'2025-09-21 12:45:00','delivered','Tongersestraat','Maastricht','53','2025-09-21 12:50:00','2025-09-21 13:20:00',NULL),(1004,4,1,'2025-09-21 20:10:00','assigned','Brusselsestraat','Maastricht','45','2025-09-21 20:15:00',NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza`
--

LOCK TABLES `pizza` WRITE;
/*!40000 ALTER TABLE `pizza` DISABLE KEYS */;
INSERT INTO `pizza` VALUES (1,'Margherita',0),(2,'Diavola',0),(3,'Quattro Formagi',0),(4,'Pepperoni',0),(5,'BBQ Chicken',0),(6,'Vegeterian',0),(7,'Capricciosa',0),(8,'Hawaiian',1),(9,'Prosciutto e Funghi',1),(10,'Tonno e Cipolla',1);
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
  `quantity` decimal(6,2) NOT NULL,
  PRIMARY KEY (`idPizza`,`idIngredients`),
  KEY `idingredients_idx` (`idIngredients`),
  CONSTRAINT `idingredients` FOREIGN KEY (`idIngredients`) REFERENCES `ingredients` (`idIngredients`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `idpizza` FOREIGN KEY (`idPizza`) REFERENCES `pizza` (`idPizza`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_ingredients`
--

LOCK TABLES `pizza_ingredients` WRITE;
/*!40000 ALTER TABLE `pizza_ingredients` DISABLE KEYS */;
INSERT INTO `pizza_ingredients` VALUES (1,1,120.00),(1,2,80.00),(1,4,0.08),(1,5,0.12),(1,6,0.01),(1,10,5.00),(1,11,2.00),(2,1,110.00),(2,2,80.00),(2,3,80.00),(2,11,1.00),(3,1,100.00),(3,2,60.00),(3,10,20.00),(4,1,110.00),(4,2,80.00),(4,3,90.00),(5,1,100.00),(5,6,30.00),(5,9,90.00),(5,12,70.00),(6,1,110.00),(6,2,80.00),(6,5,50.00),(6,6,30.00),(6,7,50.00),(6,8,30.00),(6,11,1.00),(7,1,110.00),(7,2,80.00),(7,4,70.00),(7,5,40.00),(7,8,20.00),(8,1,110.00),(8,2,80.00),(8,4,60.00),(8,13,80.00),(9,1,110.00),(9,2,80.00),(9,4,70.00),(9,5,50.00),(10,1,100.00),(10,2,80.00),(10,6,40.00),(10,8,10.00),(10,14,90.00);
/*!40000 ALTER TABLE `pizza_ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pricing_policy`
--

DROP TABLE IF EXISTS `pricing_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pricing_policy` (
  `margin` decimal(5,2) NOT NULL,
  `vat` decimal(5,2) NOT NULL,
  `from` date NOT NULL,
  `to` date DEFAULT NULL,
  `ingredient` int NOT NULL,
  PRIMARY KEY (`ingredient`),
  CONSTRAINT `ingredient` FOREIGN KEY (`ingredient`) REFERENCES `ingredients` (`idIngredients`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pricing_policy`
--

LOCK TABLES `pricing_policy` WRITE;
/*!40000 ALTER TABLE `pricing_policy` DISABLE KEYS */;
INSERT INTO `pricing_policy` VALUES (40.00,9.00,'2025-09-04',NULL,1),(40.00,9.00,'2025-09-04',NULL,2),(40.00,9.00,'2025-09-04',NULL,3),(40.00,9.00,'2025-09-04',NULL,4),(40.00,9.00,'2025-09-04',NULL,5),(40.00,9.00,'2025-09-04',NULL,6),(40.00,9.00,'2025-09-04',NULL,7),(40.00,9.00,'2025-09-04',NULL,8),(40.00,9.00,'2025-09-04',NULL,9),(40.00,9.00,'2025-09-04',NULL,10),(40.00,9.00,'2025-09-04',NULL,11),(40.00,9.00,'2025-09-04',NULL,12),(40.00,9.00,'2025-09-04',NULL,13),(40.00,9.00,'2025-09-04',NULL,14);
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
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `price` decimal(3,2) NOT NULL,
  PRIMARY KEY (`idproduct`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'Coca-Cola 330ml',1,1,2.00),(2,'Coca-Cola Zero 330ml',1,1,2.00),(3,'Fanta Orange 330ml',1,1,2.00),(4,'Sprite 330ml',1,1,2.00),(5,'Mineral Water (Still)',1,1,1.00),(6,'Sparkling Water',1,1,1.00),(7,'Tiramisu',2,1,3.50),(8,'Chocolate Brownie',2,1,2.50),(9,'Vanilla Gelato',2,1,2.50),(10,'Chocolate Gelato',2,1,2.50);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_pizza_price`
--

DROP TABLE IF EXISTS `v_pizza_price`;
/*!50001 DROP VIEW IF EXISTS `v_pizza_price`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pizza_price` AS SELECT 
 1 AS `pizza_name`,
 1 AS `price`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `menu`
--

/*!50001 DROP VIEW IF EXISTS `menu`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `menu` AS select `v`.`pizza_name` AS `Items`,`v`.`price` AS `Price` from `v_pizza_price` `v` union select `pr`.`name` AS `name`,`pr`.`price` AS `price` from `product` `pr` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pizza_price`
--

/*!50001 DROP VIEW IF EXISTS `v_pizza_price`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pizza_price` AS select `p`.`pizza_name` AS `pizza_name`,round(sum((((`pi`.`quantity` * `i`.`unit_cost`) * (1 + (coalesce(`pp`.`margin`,`gp`.`margin`) / 100))) * (1 + (coalesce(`pp`.`vat`,`gp`.`vat`) / 100)))),2) AS `price` from ((((`pizza` `p` join `pizza_ingredients` `pi` on((`pi`.`idPizza` = `p`.`idPizza`))) join `ingredients` `i` on((`i`.`idIngredients` = `pi`.`idIngredients`))) left join `pricing_policy` `pp` on(((`pp`.`ingredient` = `i`.`idIngredients`) and (curdate() >= `pp`.`from`) and ((`pp`.`to` is null) or (curdate() < `pp`.`to`))))) left join `pricing_policy` `gp` on((`gp`.`ingredient` = 0))) group by `p`.`pizza_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-01 11:58:59
