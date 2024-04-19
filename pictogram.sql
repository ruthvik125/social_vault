-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 19, 2024 at 01:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pictogram`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `FilterPosts` (IN `session_user_id` INT)   BEGIN
    SELECT * FROM posts
    WHERE user_id = session_user_id 
    OR user_id IN (SELECT user_id FROM follow_list WHERE user_id = session_user_id);
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `checkFollowStatus` (`user_id` INT, `current_user_id` INT) RETURNS INT(11)  BEGIN
    DECLARE status INT DEFAULT 0;

   SELECT count(*) INTO status FROM follow_list WHERE follower_id=current_user_id && user_id=user_id ;
    
    RETURN status;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getposterID` (`post_id` INT) RETURNS INT(11)  BEGIN
    DECLARE uid INT;
    SELECT user_id INTO uid FROM posts where posts.id=post_id;
    RETURN uid;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_comment_count` (`pid` INT) RETURNS INT(11)  BEGIN
    DECLARE comment_count INT;
    SELECT COUNT(*) INTO comment_count FROM comments WHERE comments.post_id=pid;
    RETURN comment_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_likes_count` (`pid` INT) RETURNS INT(11)  BEGIN
    DECLARE likes_count INT;
    SELECT COUNT(*) INTO likes_count FROM likes WHERE likes.post_id=pid;
    RETURN likes_count;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `full_name` varchar(250) NOT NULL,
  `email` varchar(250) NOT NULL,
  `password` text NOT NULL,
  `password_text` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `full_name`, `email`, `password`, `password_text`) VALUES
(1, 'Dev Ninja', 'admin@pictogram.com', 'c68710d3fe56fc88f7905cb15f06cf5c', '14271427'),
(2, 'blah', 'admin@gmail.com', 'password', 'password'),
(3, 'blah', 'admin@gmail.com', 'password', 'password');

-- --------------------------------------------------------

--
-- Table structure for table `block_list`
--

CREATE TABLE `block_list` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `blocked_user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`id`, `post_id`, `user_id`, `comment`, `created_at`) VALUES
(52, 17, 13, 'hello', '2024-04-16 05:49:58'),
(53, 18, 13, 'world', '2024-04-16 05:36:04'),
(57, 20, 14, 'hello, tihs is a comment', '2024-04-18 21:32:46'),
(58, 17, 13, 'commente', '2024-04-19 09:34:49'),
(59, 20, 16, 'hello', '2024-04-19 10:29:29');

--
-- Triggers `comments`
--
DELIMITER $$
CREATE TRIGGER `comment_notification` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
	DECLARE poster_id INT;
    SELECT getposterID(NEW.post_id) INTO poster_id;
	IF poster_id != NEW.user_id THEN
    INSERT INTO notifications(from_user_id,to_user_id,message,post_id) 
    VALUES(NEW.user_id,poster_id,'commented on your post',NEW.post_id);
    end IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `follow_list`
--

CREATE TABLE `follow_list` (
  `id` int(11) NOT NULL,
  `follower_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `follow_list`
--

INSERT INTO `follow_list` (`id`, `follower_id`, `user_id`) VALUES
(88, 13, 14),
(89, 14, 13),
(90, 16, 13);

--
-- Triggers `follow_list`
--
DELIMITER $$
CREATE TRIGGER `follow_notification` AFTER INSERT ON `follow_list` FOR EACH ROW BEGIN
    INSERT INTO notifications(from_user_id,to_user_id,message) 
    VALUES(NEW.follower_id,NEW.user_id,'is following you');
  
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `unfollow_notification` AFTER DELETE ON `follow_list` FOR EACH ROW BEGIN
    INSERT INTO notifications(from_user_id,to_user_id,message) 
  VALUES(OLD.follower_id,OLD.user_id,'un followed you');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE `likes` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `likes`
--

INSERT INTO `likes` (`id`, `post_id`, `user_id`) VALUES
(100, 17, 13),
(103, 20, 14),
(104, 20, 13);

--
-- Triggers `likes`
--
DELIMITER $$
CREATE TRIGGER `like_notification` AFTER INSERT ON `likes` FOR EACH ROW BEGIN
	DECLARE poster_id INT;
    SELECT getposterID(NEW.post_id) INTO poster_id;
	IF poster_id != NEW.user_id THEN
    INSERT INTO notifications(from_user_id,to_user_id,message,post_id) 
    VALUES(NEW.user_id,poster_id,'liked your post',NEW.post_id);
    end IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `unlike_notification` AFTER DELETE ON `likes` FOR EACH ROW BEGIN
	DECLARE poster_id INT;
    SELECT getposterID(OLD.post_id) INTO poster_id;
	IF poster_id != OLD.user_id THEN
    INSERT INTO notifications(from_user_id,to_user_id,message,post_id) 
    VALUES(OLD.user_id,poster_id,'unliked your post',OLD.post_id);
    end IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `from_user_id` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `msg` text NOT NULL,
  `read_status` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `from_user_id`, `to_user_id`, `msg`, `read_status`, `created_at`) VALUES
(48, 13, 14, 'hi', 0, '2024-04-19 09:35:54');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `from_user_id` int(11) NOT NULL,
  `read_status` int(11) NOT NULL DEFAULT 0,
  `post_id` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `to_user_id`, `message`, `created_at`, `from_user_id`, `read_status`, `post_id`) VALUES
(116, 13, 'started following you !', '2024-04-12 05:22:44', 14, 1, '0'),
(117, 14, 'started following you !', '2024-04-12 05:23:29', 13, 1, '0'),
(118, 14, 'New Post added', '2024-04-18 07:18:17', 13, 1, '14'),
(119, 14, 'New Post added', '2024-04-18 07:22:00', 13, 1, '14'),
(120, 13, 'commented on your post', '2024-04-18 21:32:46', 14, 1, '20'),
(121, 13, 'liked your post !', '2024-04-18 21:40:02', 14, 1, '20'),
(122, 13, 'liked your post', '2024-04-18 21:40:02', 14, 1, '20'),
(123, 13, 'liked your post !', '2024-04-18 21:40:09', 14, 1, '17'),
(124, 13, 'liked your post', '2024-04-18 21:40:09', 14, 1, '17'),
(125, 13, 'unliked your post !', '2024-04-18 21:41:29', 14, 1, '20'),
(126, 13, 'Unfollowed you !', '2024-04-18 21:51:50', 14, 1, '0'),
(127, 13, 'Unfollowed you !', '2024-04-18 21:51:56', 14, 1, '0'),
(128, 13, 'Unfollowed you !', '2024-04-18 21:52:29', 14, 1, '0'),
(129, 13, 'is following you', '2024-04-19 05:37:50', 14, 1, NULL),
(130, 13, 'liked your post', '2024-04-19 05:37:59', 14, 1, '20'),
(131, 13, 'unliked your post', '2024-04-19 07:37:50', 14, 1, '20'),
(132, 13, 'liked your post', '2024-04-19 07:37:51', 14, 1, '20'),
(133, 13, 'unliked your post', '2024-04-19 07:37:53', 14, 1, '17'),
(134, 13, 'is following you', '2024-04-19 10:28:19', 16, 1, NULL),
(135, 13, 'commented on your post', '2024-04-19 10:29:29', 16, 1, '20');

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `post_img` text NOT NULL,
  `post_text` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`id`, `user_id`, `post_img`, `post_text`, `created_at`) VALUES
(17, 13, '1713245746dancing.jpg', 'this is a dancer', '2024-04-16 05:35:46'),
(20, 13, '1713277905picasso.jpg', '', '2024-04-16 14:31:45');

--
-- Triggers `posts`
--
DELIMITER $$
CREATE TRIGGER `post_delete` AFTER DELETE ON `posts` FOR EACH ROW BEGIN
	DELETE FROM comments WHERE post_id = OLD.id;
    DELETE FROM likes WHERE post_id = OLD.id;
    UPDATE notifications SET read_status=2 WHERE 		  post_id=OLD.id && to_user_id=OLD.user_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `gender` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` text NOT NULL,
  `profile_pic` varchar(250) NOT NULL DEFAULT 'default_profile.jpg',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `ac_status` int(11) NOT NULL COMMENT '0=not verified,1=active,2=blocked'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `gender`, `email`, `username`, `password`, `profile_pic`, `created_at`, `updated_at`, `ac_status`) VALUES
(13, 'Pragya', 'G', 2, 'pragyag2575@gmail.com', 'prg', 'e73d45437ff69d701ffd982bdccdaafc', 'default_profile.jpg', '2024-04-11 11:07:02', '2024-04-11 11:07:02', 0),
(14, 'ye', 'yu', 0, 'wee@gmail.com', 'hello', '5d41402abc4b2a76b9719d911017c592', 'default_profile.jpg', '2024-04-12 05:22:26', '2024-04-18 02:47:05', 1),
(15, 'bruh', 'B', 0, 'bruh@gmail.com', 'bruh', '2e315dcaa77983999bf11106c65229dc', 'default_profile.jpg', '2024-04-19 07:45:44', '2024-04-19 07:45:44', 0),
(16, 'hi', 'hi', 0, 'hi@gmail.com', 'hi', '49f68a5c8493ec2c0bf489821c21fc3b', '1713519556download.jpg', '2024-04-19 08:22:32', '2024-04-19 09:39:16', 0),
(17, 'dfjdlkfj1212', 'dfdasf', 0, 'aruthvik125@gmail.com', 'aruthvik125', '79f9a9b31a3148009b9935af34f89637', 'default_profile.jpg', '2024-04-19 10:49:58', '2024-04-19 10:49:58', 0),
(18, 'the', 't', 0, 'monkey@gmail.com', 'blah', '45a79ac9ffbe49d35071f048796bb24c', 'default_profile.jpg', '2024-04-19 10:54:34', '2024-04-19 10:54:34', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `block_list`
--
ALTER TABLE `block_list`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `follow_list`
--
ALTER TABLE `follow_list`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `block_list`
--
ALTER TABLE `block_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `follow_list`
--
ALTER TABLE `follow_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT for table `likes`
--
ALTER TABLE `likes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
