-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- 主機： 127.0.0.1
-- 產生時間： 2022 年 12 月 10 日 14:45
-- 伺服器版本： 10.4.27-MariaDB
-- PHP 版本： 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `tbl_sys`
--

DELIMITER $$
--
-- 程序
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getSuggestTable` (IN `no_of_ppl` INT, IN `rest_id` VARCHAR(50) CHARSET utf8mb4)   BEGIN
	DECLARE tableCnt INT;
	SELECT IFNULL(count(*), 0) INTO tableCnt 
	FROM tables
	where tables.capacity >= no_of_ppl
	and tables.rest_id = rest_id
	and tables.status = 'ACTIVE'
	and tables.table_id NOT IN (Select suggests.table_id 
								from suggests 
								where status = 'PENDING');
	IF tableCnt > 0 THEN
		INSERT INTO suggests (no_of_ppl,status,table_id,updated_at,created_at)
		SELECT no_of_ppl,"PENDING",tables.table_id,NOW(),NOW() FROM tables
		where tables.capacity >= no_of_ppl
		and tables.rest_id = rest_id
		and tables.status = 'ACTIVE'
		and tables.table_id NOT IN (
			Select suggests.table_id from suggests where status = 'PENDING')
		order by capacity desc LIMIT 1;
	ELSE
		INSERT INTO suggests (no_of_ppl,status,table_id,updated_at,created_at)
		SELECT no_of_ppl,"WAITING",tables.table_id,NOW(),NOW() FROM tables
		where tables.capacity >= no_of_ppl
		and tables.rest_id = rest_id
		and tables.table_id NOT IN (
			Select suggests.table_id from suggests where status = 'WAITING')
		order by capacity desc LIMIT 1;
	END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- 資料表結構 `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2019_08_19_000000_create_failed_jobs_table', 1),
(4, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(5, '2022_12_04_143333_create_posts_table', 2);

-- --------------------------------------------------------

--
-- 資料表結構 `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `posts`
--

CREATE TABLE `posts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `rests`
--

CREATE TABLE `rests` (
  `rest_id` varchar(50) NOT NULL,
  `rest_x` decimal(5,0) NOT NULL,
  `rest_y` decimal(5,0) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 傾印資料表的資料 `rests`
--

INSERT INTO `rests` (`rest_id`, `rest_x`, `rest_y`, `created_at`, `updated_at`) VALUES
('tst001', '800', '800', '2022-12-04 14:46:57', '2022-12-04 15:19:28'),
('tsw001', '800', '800', '2022-12-04 14:53:03', '2022-12-04 14:55:48'),
('Hl001', '800', '800', '2022-12-06 02:38:25', '2022-12-06 02:38:25'),
('Tts001', '800', '800', '2022-12-09 06:43:46', '2022-12-09 06:43:46'),
('lofu001', '800', '800', '2022-12-10 00:49:32', '2022-12-10 01:07:49');

-- --------------------------------------------------------

--
-- 資料表結構 `robots`
--

CREATE TABLE `robots` (
  `robot_id` varchar(50) NOT NULL,
  `rest_id` varchar(50) NOT NULL,
  `table_id` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `suggests`
--

CREATE TABLE `suggests` (
  `suggest_id` int(11) NOT NULL,
  `no_of_ppl` int(50) NOT NULL,
  `status` varchar(255) NOT NULL,
  `table_id` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 傾印資料表的資料 `suggests`
--

INSERT INTO `suggests` (`suggest_id`, `no_of_ppl`, `status`, `table_id`, `created_at`, `updated_at`) VALUES
(3, 4, 'REJECTED', 81, '2022-12-05 08:24:20', '2022-12-05 00:32:07'),
(4, 4, 'APPROVED', 81, '2022-12-05 08:52:16', '2022-12-05 00:52:33'),
(5, 4, 'APPROVED', 81, '2022-12-05 08:54:56', '2022-12-05 00:55:16'),
(6, 4, 'APPROVED', 74, '2022-12-05 10:21:05', '2022-12-05 03:12:19'),
(7, 4, 'APPROVED', 76, '2022-12-05 10:21:48', '2022-12-05 03:24:27'),
(8, 4, 'REJECTED', 74, '2022-12-05 10:22:37', '2022-12-05 03:13:59'),
(9, 4, 'REJECTED', 81, '2022-12-05 11:26:23', '2022-12-05 03:33:26'),
(10, 4, 'REJECTED', 76, '2022-12-05 11:26:24', '2022-12-05 03:27:00'),
(11, 4, 'REJECTED', 81, '2022-12-05 13:44:07', '2022-12-05 05:48:22'),
(12, 4, 'REJECTED', 81, '2022-12-05 13:49:07', '2022-12-08 00:45:08'),
(13, 4, 'APPROVED', 81, '2022-12-05 13:52:25', '2022-12-06 02:38:53'),
(14, 4, 'REJECTED', 81, '2022-12-08 13:31:06', '2022-12-08 05:31:40'),
(15, 4, 'REJECTED', 76, '2022-12-08 13:31:06', '2022-12-08 05:31:34'),
(16, 4, 'REJECTED', 76, '2022-12-08 13:31:46', '2022-12-08 05:32:00'),
(17, 4, 'REJECTED', 76, '2022-12-08 13:31:54', '2022-12-08 05:32:52'),
(18, 4, 'REJECTED', 81, '2022-12-08 13:33:51', '2022-12-08 05:33:56'),
(19, 4, 'REJECTED', 81, '2022-12-08 13:33:58', '2022-12-08 05:34:56'),
(20, 4, 'REJECTED', 81, '2022-12-08 13:34:03', '2022-12-08 05:34:17'),
(21, 4, 'REJECTED', 76, '2022-12-08 13:34:41', '2022-12-08 05:35:03'),
(22, 4, 'REJECTED', 76, '2022-12-08 13:36:18', '2022-12-08 05:36:50'),
(23, 4, 'REJECTED', 76, '2022-12-08 13:36:45', '2022-12-08 05:36:58'),
(24, 4, 'REJECTED', 81, '2022-12-08 13:39:40', '2022-12-08 05:39:56'),
(25, 4, 'REJECTED', 76, '2022-12-08 13:39:42', '2022-12-08 05:39:54'),
(26, 5, 'REJECTED', 29, '2022-12-08 19:02:16', '2022-12-10 03:38:12'),
(27, 4, 'APPROVED', 29, '2022-12-08 19:17:28', '2022-12-08 11:17:36'),
(28, 4, 'APPROVED', 81, '2022-12-08 19:21:21', '2022-12-08 11:21:24'),
(29, 5, 'APPROVED', 81, '2022-12-08 19:21:56', '2022-12-08 11:22:00'),
(30, 7, 'APPROVED', 81, '2022-12-08 19:23:11', '2022-12-08 11:23:18'),
(31, 4, 'APPROVED', 81, '2022-12-08 19:24:33', '2022-12-08 11:24:37'),
(32, 3, 'APPROVED', 81, '2022-12-08 19:25:42', '2022-12-08 11:25:49'),
(33, 2, 'APPROVED', 81, '2022-12-08 19:26:49', '2022-12-08 11:26:53'),
(34, 4, 'APPROVED', 81, '2022-12-08 19:28:22', '2022-12-08 11:28:25'),
(35, 4, 'APPROVED', 29, '2022-12-08 19:29:46', '2022-12-08 11:29:51'),
(36, 3, 'REJECTED', 86, '2022-12-10 05:25:23', '2022-12-09 22:20:42'),
(37, 3, 'REJECTED', 87, '2022-12-10 06:00:09', '2022-12-09 22:20:41'),
(38, 3, 'REJECTED', 86, '2022-12-10 06:06:25', '2022-12-09 22:20:47'),
(39, 3, 'REJECTED', 87, '2022-12-10 06:09:17', '2022-12-09 22:20:50'),
(40, 3, 'REJECTED', 87, '2022-12-10 06:09:54', '2022-12-09 22:20:52'),
(41, 2, 'REJECTED', 29, '2022-12-10 06:21:25', '2022-12-09 22:23:32'),
(42, 2, 'REJECTED', 29, '2022-12-10 06:23:42', '2022-12-09 22:27:59'),
(43, 2, 'REJECTED', 29, '2022-12-10 06:28:08', '2022-12-09 22:28:55'),
(44, 5, 'APPROVED', 29, '2022-12-10 06:29:00', '2022-12-09 22:29:09'),
(45, 3, 'APPROVED', 28, '2022-12-10 06:31:07', '2022-12-09 22:31:11'),
(46, 8, 'REJECTED', 30, '2022-12-10 06:34:56', '2022-12-09 22:38:29'),
(47, 4, 'REJECTED', 74, '2022-12-10 06:36:03', '2022-12-09 22:38:26'),
(48, 7, 'APPROVED', 30, '2022-12-10 06:38:41', '2022-12-09 22:39:28'),
(49, 8, 'REJECTED', 102, '2022-12-10 09:24:15', '2022-12-10 01:24:27'),
(50, 8, 'APPROVED', 102, '2022-12-10 09:28:07', '2022-12-10 01:30:13'),
(51, 8, 'REJECTED', 106, '2022-12-10 09:30:40', '2022-12-10 01:40:30'),
(52, 8, 'APPROVED', 106, '2022-12-10 09:40:33', '2022-12-10 01:40:45'),
(53, 8, 'APPROVED', 108, '2022-12-10 09:41:14', '2022-12-10 01:41:24'),
(54, 8, 'APPROVED', 100, '2022-12-10 09:42:22', '2022-12-10 01:45:29'),
(55, 8, 'REJECTED', 101, '2022-12-10 09:48:29', '2022-12-10 01:57:15'),
(56, 8, 'REJECTED', 101, '2022-12-10 09:57:30', '2022-12-10 01:59:08'),
(58, 4, 'APPROVED', 29, '2022-12-10 11:03:59', '2022-12-10 03:46:54'),
(59, 8, 'APPROVED', 29, '2022-12-10 11:47:23', '2022-12-10 03:47:51'),
(60, 8, 'APPROVED', 74, '2022-12-10 11:48:07', '2022-12-10 03:48:16'),
(61, 8, 'APPROVED', 29, '2022-12-10 12:10:27', '2022-12-10 04:16:44');

-- --------------------------------------------------------

--
-- 資料表結構 `tables`
--

CREATE TABLE `tables` (
  `table_id` int(11) NOT NULL,
  `table_no` varchar(255) NOT NULL,
  `rest_id` varchar(50) NOT NULL,
  `capacity` int(11) NOT NULL,
  `table_x` varchar(255) NOT NULL,
  `table_y` varchar(255) NOT NULL,
  `status` varchar(50) NOT NULL,
  `robot_id` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 傾印資料表的資料 `tables`
--

INSERT INTO `tables` (`table_id`, `table_no`, `rest_id`, `capacity`, `table_x`, `table_y`, `status`, `robot_id`, `created_at`, `updated_at`) VALUES
(28, 'table1', 'tsw001', 10, '165.00694274902', '296.93402099609', 'INACTIVE', 'robot1', '2022-12-04 14:55:49', '2022-12-09 22:31:11'),
(29, 'table2', 'tsw001', 15, '392.00694274902', '289.93402099609', 'INACTIVE', 'robot2', '2022-12-04 14:55:49', '2022-12-10 04:16:44'),
(30, 'table3', 'tsw001', 8, '624.00694274902', '270.93402099609', 'INACTIVE', 'robot1', '2022-12-04 14:55:49', '2022-12-09 22:39:28'),
(74, 'table1', 'tst001', 8, '177.01388549805', '363.15623474121', 'INACTIVE', 'robot1', '2022-12-04 15:19:29', '2022-12-10 03:48:16'),
(75, 'table2', 'tst001', 8, '360.01388549805', '338.15623474121', 'ACTIVE', 'robot2', '2022-12-04 15:19:29', '2022-12-05 03:22:20'),
(76, 'table3', 'tst001', 10, '534.01388549805', '321.15623474121', 'INACTIVE', 'robot2', '2022-12-04 15:19:29', '2022-12-05 05:48:12'),
(77, 'table4', 'tst001', 8, '185.01388549805', '558.15625', 'ACTIVE', 'robot1', '2022-12-04 15:19:30', '2022-12-05 03:17:32'),
(78, 'table5', 'tst001', 8, '361.01388549805', '535.15625', 'ACTIVE', 'robot1', '2022-12-04 15:19:30', '2022-12-05 03:14:26'),
(79, 'table6', 'tst001', 8, '508.01388549805', '497.15625', 'ACTIVE', 'robot1', '2022-12-04 15:19:30', '2022-12-04 15:19:30'),
(80, 'table7', 'tst001', 8, '207.01388549805', '692.15625', 'ACTIVE', 'robot1', '2022-12-04 15:19:30', '2022-12-04 15:19:30'),
(81, 'table8', 'tst001', 12, '371.01388549805', '669.15625', 'INACTIVE', 'robot2', '2022-12-04 15:19:30', '2022-12-08 11:28:25'),
(82, 'table9', 'tst001', 8, '565.01388549805', '659.15625', 'ACTIVE', 'robot1', '2022-12-04 15:19:30', '2022-12-04 15:19:30'),
(83, 'table1', 'Hl001', 9, '268', '215', 'ACTIVE', 'Robot1', '2022-12-06 02:38:25', '2022-12-06 02:38:25'),
(84, 'table2', 'Hl001', 8, '434', '215', 'ACTIVE', 'Robot01', '2022-12-06 02:38:25', '2022-12-06 02:38:25'),
(85, 'table3', 'Hl001', 8, '132', '192', 'ACTIVE', 'robot01', '2022-12-06 02:38:25', '2022-12-06 02:38:25'),
(86, 'table3', 'Tts001', 10, '584', '311', 'ACTIVE', 'Robot2', '2022-12-09 06:43:46', '2022-12-09 06:43:46'),
(87, 'table1', 'Tts001', 9, '242', '338', 'ACTIVE', 'Robot1', '2022-12-09 06:43:46', '2022-12-09 06:43:46'),
(88, 'table2', 'Tts001', 8, '413', '292', 'ACTIVE', 'robot2', '2022-12-09 06:43:47', '2022-12-09 06:43:47'),
(100, 'table2', 'lofu001', 8, '386.5', '213.375', 'INACTIVE', 'robot01', '2022-12-10 01:07:49', '2022-12-10 01:45:29'),
(101, 'table3', 'lofu001', 8, '625.5', '195.375', 'ACTIVE', 'robot01', '2022-12-10 01:07:49', '2022-12-10 01:07:49'),
(102, 'table4', 'lofu001', 12, '154.5', '384.375', 'ACTIVE', 'robot01', '2022-12-10 01:07:50', '2022-12-10 02:14:39'),
(103, 'table1', 'lofu001', 5, '163.5', '216.375', 'ACTIVE', 'robot2', '2022-12-10 01:07:50', '2022-12-10 01:07:50'),
(104, 'table8', 'lofu001', 5, '362.5', '575.375', 'ACTIVE', 'robot01', '2022-12-10 01:07:50', '2022-12-10 01:07:50'),
(105, 'table6', 'lofu001', 6, '623.5', '373.375', 'ACTIVE', 'robot01', '2022-12-10 01:07:50', '2022-12-10 01:07:50'),
(106, 'table9', 'lofu001', 12, '620.5', '568.375', 'INACTIVE', 'robot01', '2022-12-10 01:07:50', '2022-12-10 01:40:45'),
(107, 'table5', 'lofu001', 8, '394.5', '376.375', 'ACTIVE', 'robot01', '2022-12-10 01:07:50', '2022-12-10 01:07:50'),
(108, 'table7', 'lofu001', 10, '147.5', '592.375', 'INACTIVE', 'robot01', '2022-12-10 01:07:50', '2022-12-10 01:41:24');

-- --------------------------------------------------------

--
-- 資料表結構 `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'test', 'test@test.com', NULL, '$2y$10$Smo0pnvhdhL3UNaYNPyyKeLMaZNr3jLp0ZcIhSUqHlZYrzHsOtkS6', NULL, '2022-12-04 06:38:26', '2022-12-04 06:38:26'),
(2, 'daniel', 'daniel@test.com', NULL, '$2y$10$jOSBvdiUwR82WF9mKN7T1es33.J56vzCh6WHjxHILsrceYGbe42fy', NULL, '2022-12-04 07:01:54', '2022-12-04 07:01:54'),
(3, 'test1', 'test1@test.com', NULL, '$2y$10$N6Fdz22JswQtgWBJuR3dNe3mFzcmMlXI/iGMYJQ9VhHJd/jkFgque', NULL, '2022-12-10 00:23:35', '2022-12-10 00:23:35');

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- 資料表索引 `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- 資料表索引 `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- 資料表索引 `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `suggests`
--
ALTER TABLE `suggests`
  ADD PRIMARY KEY (`suggest_id`);

--
-- 資料表索引 `tables`
--
ALTER TABLE `tables`
  ADD PRIMARY KEY (`table_id`);

--
-- 資料表索引 `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `posts`
--
ALTER TABLE `posts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `suggests`
--
ALTER TABLE `suggests`
  MODIFY `suggest_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `tables`
--
ALTER TABLE `tables`
  MODIFY `table_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
