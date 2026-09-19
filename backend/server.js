const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const multer = require("multer");
const cloudinary = require("cloudinary").v2; 
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const Book = require("./models/Book");
const Author = require("./models/author");
const Notification = require("./models/notification");

const app = express();

// =====================================
// MULTER IMAGE UPLOAD SETUP
// =====================================

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },

  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 20 * 1024 * 1024, // 20 MB
  },
});

// =====================================
// MIDDLEWARE
// =====================================

app.use(cors());

app.use(express.json());

app.use(
  express.urlencoded({
    extended: true,
  })
);

app.use("/uploads", express.static("uploads"));

// =====================================
// MONGODB CONNECTION
// =====================================

mongoose.connect(
  process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/mybookapp",
  {
    dbName: "mybookapp",
  }
)
  .then(() => {
    console.log("MongoDB Connected");

    const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
  })
  .catch((error) => {
    console.log("MongoDB Connection Error:", error);
  });

// =====================================
// HOME
// =====================================

app.get("/", (req, res) => {
  res.send("Book API is working!");
});

// =====================================
// GET ALL BOOKS
// =====================================

app.get("/books", async (req, res) => {
  try {
    const books = await Book.find();

    res.json(books);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});
// =====================================
// REMOVE OLD FAVOURITE CATEGORY
// BOOKS WILL NOT BE DELETED
// =====================================

app.put("/books/remove-old-favourite", async (req, res) => {
  try {
    const result = await Book.updateMany(
      { category: "favourite" },
      { $set: { category: null } }
    );

    res.json({
      success: true,
      message: "Old Favourite category removed",
      modifiedCount: result.modifiedCount,
    });
  } catch (error) {
    console.error("Remove Category Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});
// =====================================
// DEVELOPER DELETE BOOK PAGE
// =====================================

app.get("/delete-book", async (req, res) => {
  try {
    const books = await Book.find();

    let bookList = "";

    books.forEach((book) => {
      bookList += `
        <div class="book">

          <div class="info">

            <h3>${book.title}</h3>

            <p>
              <b>Author:</b>
              ${book.author || ""}
            </p>

            <p>
              <b>Price:</b>
              ₹${book.price || 0}
            </p>

            <p>
              <b>Book ID:</b>
              ${book._id}
            </p>

          </div>

          <form
            method="POST"
            action="/delete-book/${book._id}"
            onsubmit="
              return confirm(
                'Kya aap is book ko permanently delete karna chahte hain?'
              );
            "
          >

            <button type="submit">
              Delete Book
            </button>

          </form>

        </div>
      `;
    });

    if (books.length === 0) {
      bookList = `
        <div class="empty">
          <h3>No books found</h3>
        </div>
      `;
    }

    res.send(`
      <html>

      <head>

        <title>Delete Books - Developer</title>

        <style>

          body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 30px;
          }

          .container {
            max-width: 800px;
            margin: auto;
          }

          h1 {
            text-align: center;
            margin-bottom: 10px;
          }

          .developer {
            text-align: center;
            color: #666;
            margin-bottom: 25px;
          }

          .book {
            background: white;
            padding: 20px;
            margin-bottom: 15px;
            border-radius: 12px;

            box-shadow:
              0 4px 12px rgba(0,0,0,0.1);

            display: flex;
            justify-content: space-between;
            align-items: center;

            gap: 20px;
          }

          .book h3 {
            margin-top: 0;
            margin-bottom: 12px;
          }

          .book p {
            margin: 7px 0;
          }

          button {
            background: #d32f2f;
            color: white;
            border: none;

            padding: 11px 18px;

            border-radius: 6px;

            cursor: pointer;

            font-size: 15px;
          }

          button:hover {
            background: #b71c1c;
          }

          .empty {
            background: white;
            padding: 30px;

            text-align: center;

            border-radius: 12px;
          }

          .links {
            text-align: center;
            margin-top: 25px;
          }

          .links a {
            display: inline-block;

            margin: 5px;

            padding: 10px 18px;

            background: black;

            color: white;

            text-decoration: none;

            border-radius: 6px;
          }

        </style>

      </head>

      <body>

        <div class="container">

          <h1>
            Delete Books
          </h1>

          <div class="developer">
            Developer Book Management
          </div>

          ${bookList}

          <div class="links">

            <a href="/add-book">
              Add New Book
            </a>

            <a href="/books">
              View Books API
            </a>

          </div>

        </div>

      </body>

      </html>
    `);

  } catch (error) {

    res.status(500).send(error.message);

  }
});

// =====================================
// DEVELOPER DELETE BOOK
// =====================================

app.post("/delete-book/:id", async (req, res) => {

  try {

    const book = await Book.findByIdAndDelete(req.params.id);

    if (!book) {

      return res.status(404).send(
        "Book not found"
      );

    }

    res.send(`
      <html>

      <head>
        <title>Book Deleted</title>
      </head>

      <body
        style="
          font-family: Arial;
          text-align: center;
          padding: 50px;
        "
      >

        <h2>
          Book Deleted Successfully! ✅
        </h2>

        <p>
          Deleted Book:
          <b>${book.title}</b>
        </p>

        <br>

        <a href="/delete-book">
          Back to Delete Books
        </a>

        <br><br>

        <a href="/add-book">
          Add New Book
        </a>

      </body>

      </html>
    `);

  } catch (error) {

    res.status(500).send(
      error.message
    );

  }

});
// =====================================
// ADD BOOK FORM
// =====================================

app.get("/add-book", (req, res) => {

  res.send(`
    <html>

    <head>

      <title>Add Book</title>

      <style>

        body {
          font-family: Arial;
          background: #f5f5f5;
          padding: 30px;
        }

        .container {
          max-width: 500px;
          margin: auto;
          background: white;
          padding: 25px;
          border-radius: 12px;
          box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        h2 {
          text-align: center;
        }

        input,
        textarea {
          width: 100%;
          padding: 10px;
          margin-top: 6px;
          margin-bottom: 15px;
          box-sizing: border-box;
        }

        button {
          width: 100%;
          padding: 12px;
          background: black;
          color: white;
          border: none;
          border-radius: 6px;
          font-size: 16px;
        }

      </style>

    </head>

    <body>

      <div class="container">

        <h2>Add New Book</h2>

        <form
          method="POST"
          action="/add-book"
          enctype="multipart/form-data"
        >

          <label>Book Title:</label>

          <input
            type="text"
            name="title"
            required
          >
<label>Author Name:</label>
<input type="text" name="authorName" required>

<label>Education:</label>
<input type="text" name="authorEducation" placeholder="MCA, BCA etc.">

<label>Author Bio:</label>
<textarea name="authorBio" placeholder="About the author..."></textarea>

<label>Author Email:</label>
<input type="email" name="authorEmail">

<label>Author Phone:</label>
<input type="text" name="authorPhone">

<label>Author Image:</label>
<input type="file" name="authorImage" accept="image/*" required>

          <label>Price:</label>

          <input
            type="number"
            name="price"
            required
          >

          <label>Description:</label>

          <textarea
            name="description"
          ></textarea>

          <label>Book Cover:</label>

          <input
            type="file"
            name="coverImage"
            accept="image/*"
            required
          >
          <label>Front Image:</label>

<input
  type="file"
  name="frontImage"
  accept="image/*"
>
  
<label>Back Image:</label>

<input
  type="file"
  name="backImage"
  accept="image/*"
>

<label>Book Category:</label>

<select
  name="category"
  required
  style="
    width: 100%;
    padding: 10px;
    margin-top: 6px;
    margin-bottom: 15px;
    box-sizing: border-box;
  "
>
  <option value="favourite">⭐ Favourite</option>
  <option value="new_release">🆕 New Release</option>
  <option value="trending">🔥 Trending</option>
</select>

<button type="submit">
  Add Book
</button>
        </form>

      </div>

    </body>

    </html>
  `);
});

// =====================================
// SAVE BOOK + IMAGE
// CREATE NOTIFICATION
// =====================================

app.post(
  "/add-book",
  upload.fields([
  { name: "coverImage", maxCount: 1 },
  { name: "frontImage", maxCount: 1 },
  { name: "backImage", maxCount: 1 },
  { name: "authorImage", maxCount: 1 },
]),

  async (req, res) => {

    try {


let coverImageUrl = "";
let frontImageUrl = "";
let backImageUrl = "";
let authorImageUrl = "";

if (req.files?.coverImage?.[0]) {
  const result = await cloudinary.uploader.upload(
    req.files.coverImage[0].path,
    {
      folder: "mybookapp/books",
    }
  );

  coverImageUrl = result.secure_url;
}

if (req.files?.frontImage?.[0]) {
  const result = await cloudinary.uploader.upload(
    req.files.frontImage[0].path,
    {
      folder: "mybookapp/books",
    }
  );

  frontImageUrl = result.secure_url;
}

if (req.files?.backImage?.[0]) {
  const result = await cloudinary.uploader.upload(
    req.files.backImage[0].path,
    {
      folder: "mybookapp/books",
    }
  );

  backImageUrl = result.secure_url;
}
if (req.files?.authorImage?.[0]) {
  const result = await cloudinary.uploader.upload(
    req.files.authorImage[0].path,
    {
      folder: "mybookapp/authors",
    }
  );

  authorImageUrl = result.secure_url;
}
const book = new Book({
  title: req.body.title,

  author: req.body.authorName,

  authorDetails: {
    name: req.body.authorName,
    education: req.body.authorEducation || "",
    bio: req.body.authorBio || "",
    image: authorImageUrl,
    email: req.body.authorEmail || "",
    phone: req.body.authorPhone || "",
  },

  price: req.body.price,
  description: req.body.description,
  coverImage: coverImageUrl,
  frontImage: frontImageUrl,
  backImage: backImageUrl,

  // Book category
  category: req.body.category,
});
      await book.save();

      // =================================
      // NEW BOOK NOTIFICATION
      // =================================

      await Notification.create({

        title: "New Book Added 📚",

        message:
          `"${book.title}" is now available to read.`,

        type: "new_book",

        bookId: book._id,

        isRead: false,

      });

      res.send(`

        <html>

        <head>

          <title>Book Added</title>

          <style>

            body {
              font-family: Arial;
              text-align: center;
              padding: 50px;
              background: #f5f5f5;
            }

            .box {
              background: white;
              max-width: 500px;
              margin: auto;
              padding: 30px;
              border-radius: 15px;
              box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            }

            a {
              display: inline-block;
              margin: 8px;
              padding: 10px 18px;
              background: black;
              color: white;
              text-decoration: none;
              border-radius: 6px;
            }

          </style>

        </head>

        <body>

          <div class="box">

            <h2>
              Book Added Successfully! ✅
            </h2>

            <p>
              Book:
              <b>${book.title}</b>
            </p>

            <p>
              Notification Created: ✅
            </p>

            <br>

            <a href="/add-book">
              Add Another Book
            </a>

            <a href="/books">
              View All Books
            </a>

          </div>

        </body>

        </html>

      `);

    } catch (error) {

      console.log(
        "Add Book Error:",
        error
      );

      res.status(500).send(
        error.message
      );

    }

  }
);
// =====================================
// ADD SPECIAL OFFER NOTIFICATION
// =====================================

app.post("/api/notifications/offer", async (req, res) => {
  try {
    const { title, message } = req.body;

    const notification = await Notification.create({
      title: title || "Special Offer 🎁",
      message: message || "A special offer is available for you.",
      type: "offer",
      isRead: false,
    });

    res.status(201).json(notification);
  } catch (error) {
    console.error("Offer Error:", error);

    res.status(500).json({
      message: "Offer notification create nahi hui",
    });
  }
});
// =====================================
// SPECIAL OFFER ADMIN PAGE
// =====================================

// =====================================
// SPECIAL OFFER ADMIN PAGE
// ADD + UPDATE + DELETE
// =====================================

app.get("/add-offer", async (req, res) => {
  try {
    const offers = await Notification.find({
      type: "offer",
    }).sort({ createdAt: -1 });

    const offerList = offers
      .map(
        (offer) => `
          <div class="offer">
            <div>
              <h3>${offer.title}</h3>
              <p>${offer.message}</p>
            </div>

            <div class="buttons">
              <a
                class="edit"
                href="/edit-offer/${offer._id}"
              >
                Edit
              </a>

              <form
                method="POST"
                action="/delete-offer/${offer._id}"
                onsubmit="return confirm('Delete this offer?');"
              >
                <button
                  class="delete"
                  type="submit"
                >
                  Delete
                </button>
              </form>
            </div>
          </div>
        `
      )
      .join("");

    res.send(`
      <!DOCTYPE html>

      <html>

      <head>

        <title>Special Offers</title>

        <style>

          body {
            font-family: Arial, sans-serif;
            background: #f7f8fc;
            padding: 30px;
          }

          .container {
            max-width: 700px;
            margin: auto;
          }

          .box {
            background: white;
            padding: 25px;
            border-radius: 18px;
            box-shadow:
              0 5px 20px
              rgba(0,0,0,0.08);
          }

          h1 {
            color: #5B4BDB;
            margin-bottom: 25px;
          }

          label {
            display: block;
            margin-top: 15px;
            margin-bottom: 6px;
            font-weight: bold;
          }

          input,
          textarea {
            width: 100%;
            box-sizing: border-box;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 10px;
            font-size: 14px;
          }

          textarea {
            height: 100px;
            resize: vertical;
          }

          .add-button {
            width: 100%;
            margin-top: 20px;
            padding: 13px;
            border: none;
            border-radius: 10px;
            background: #5B4BDB;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
          }

          .offer {
            background: white;
            padding: 18px;
            margin-top: 15px;
            border-radius: 15px;
            box-shadow:
              0 3px 12px
              rgba(0,0,0,0.06);
          }

          .offer h3 {
            margin: 0;
            color: #333;
          }

          .offer p {
            color: #666;
          }

          .buttons {
            display: flex;
            gap: 10px;
            align-items: center;
          }

          .edit {
            background: #5B4BDB;
            color: white;
            padding: 8px 14px;
            border-radius: 8px;
            text-decoration: none;
          }

          .delete {
            background: #e53935;
            color: white;
            padding: 8px 14px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
          }

        </style>

      </head>

      <body>

        <div class="container">

          <div class="box">

            <h1>🎁 Special Offers</h1>

            <form
              method="POST"
              action="/add-offer"
            >

              <label>
                Offer Title
              </label>

              <input
                type="text"
                name="title"
                placeholder="Special Book Offer 🎁"
                required
              >

              <label>
                Offer Message
              </label>

              <textarea
                name="message"
                placeholder="Get 20% off on selected books."
                required
              ></textarea>

              <button
                class="add-button"
                type="submit"
              >
                Add Special Offer
              </button>

            </form>

          </div>

          <br>

          <h2>
            Existing Offers
          </h2>

          ${offerList || "<p>No offers available.</p>"}

        </div>

      </body>

      </html>
    `);

  } catch (error) {

    console.error(
      "Offer Page Error:",
      error
    );

    res.status(500).send(
      "Offers load nahi ho paaye."
    );
  }
});
// =====================================
// EDIT SPECIAL OFFER PAGE
// =====================================

app.get("/edit-offer/:id", async (req, res) => {
  try {
    const offer = await Notification.findById(
      req.params.id
    );

    if (!offer || offer.type !== "offer") {
      return res.status(404).send(
        "Offer nahi mila."
      );
    }

    res.send(`
      <!DOCTYPE html>

      <html>

      <head>

        <title>Edit Special Offer</title>

        <style>

          body {
            font-family: Arial, sans-serif;
            background: #f7f8fc;
            padding: 40px;
          }

          .box {
            max-width: 500px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 18px;
            box-shadow:
              0 5px 20px
              rgba(0,0,0,0.08);
          }

          h2 {
            color: #5B4BDB;
          }

          label {
            display: block;
            margin-top: 15px;
            margin-bottom: 6px;
            font-weight: bold;
          }

          input,
          textarea {
            width: 100%;
            box-sizing: border-box;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 10px;
            font-size: 14px;
          }

          textarea {
            height: 120px;
          }

          button {
            width: 100%;
            margin-top: 20px;
            padding: 13px;
            border: none;
            border-radius: 10px;
            background: #5B4BDB;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
          }

        </style>

      </head>

      <body>

        <div class="box">

          <h2>
            ✏️ Edit Special Offer
          </h2>

          <form
            method="POST"
            action="/edit-offer/${offer._id}"
          >

            <label>
              Offer Title
            </label>

            <input
              type="text"
              name="title"
              value="${offer.title}"
              required
            >

            <label>
              Offer Message
            </label>

            <textarea
              name="message"
              required
            >${offer.message}</textarea>

            <button type="submit">
              Update Offer
            </button>

          </form>

        </div>

      </body>

      </html>
    `);

  } catch (error) {

    console.error(
      "Edit Offer Page Error:",
      error
    );

    res.status(500).send(
      "Edit page open nahi hui."
    );
  }
});
// =====================================
// UPDATE SPECIAL OFFER
// =====================================

app.post("/edit-offer/:id", async (req, res) => {
  try {
    const { title, message } = req.body;

    await Notification.findByIdAndUpdate(
      req.params.id,
      {
        title: title,
        message: message,
      },
      {
        new: true,
      }
    );

    res.redirect("/add-offer");

  } catch (error) {

    console.error(
      "Update Offer Error:",
      error
    );

    res.status(500).send(
      "Offer update nahi hui."
    );
  }
});
// =====================================
// DELETE SPECIAL OFFER
// =====================================

app.post("/delete-offer/:id", async (req, res) => {
  try {
    await Notification.findByIdAndDelete(
      req.params.id
    );

    res.redirect("/add-offer");

  } catch (error) {

    console.error(
      "Delete Offer Error:",
      error
    );

    res.status(500).send(
      "Offer delete nahi hui."
    );
  }
});
// =====================================
// SAVE SPECIAL OFFER
// =====================================

app.post("/add-offer", async (req, res) => {
  try {
    const { title, message } = req.body;

    await Notification.create({
      title: title,
      message: message,
      type: "offer",
      isRead: false,
    });

    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Offer Added</title>
      </head>

      <body
        style="
          font-family: Arial;
          text-align: center;
          padding: 50px;
        "
      >

        <h2>✅ Special Offer Added Successfully!</h2>

        <p>
          Notification successfully MongoDB me save ho gayi.
        </p>

        <br>

        <a href="/add-offer">
          ➕ Add Another Offer
        </a>

      </body>
      </html>
    `);

  } catch (error) {
    console.error("Offer Save Error:", error);

    res.status(500).send(`
      <h2>❌ Special Offer add nahi hui</h2>
      <p>Please server terminal check karein.</p>
    `);
  }
});
// =====================================
// NOTIFICATION - GET ALL
// =====================================

app.get(
  "/api/notifications",
  async (req, res) => {

    try {

      const notifications =
        await Notification.find()
          .sort({
            createdAt: -1,
          });

      res.json(notifications);

    } catch (error) {

      console.log(
        "Notification Error:",
        error
      );

      res.status(500).json({

        error:
          error.message,

      });

    }

  }
);

// =====================================
// NOTIFICATION - UNREAD COUNT
// =====================================

app.get(
  "/api/notifications/unread-count",
  async (req, res) => {

    try {

      const count =
        await Notification.countDocuments({
          isRead: false,
        });

      res.json({

        count: count,

      });

    } catch (error) {

      res.status(500).json({

        error:
          error.message,

      });

    }

  }
);

// =====================================
// MARK ONE AS READ
// =====================================

app.put(
  "/api/notifications/:id/read",
  async (req, res) => {

    try {

      const notification =
        await Notification.findByIdAndUpdate(

          req.params.id,

          {
            isRead: true,
          },

          {
            new: true,
          }

        );

      if (!notification) {

        return res.status(404).json({

          message:
            "Notification not found",

        });

      }

      res.json(notification);

    } catch (error) {

      res.status(500).json({

        error:
          error.message,

      });

    }

  }
);

// =====================================
// MARK ALL AS READ
// =====================================

app.put(
  "/api/notifications/read-all",
  async (req, res) => {

    try {

      await Notification.updateMany(

        {
          isRead: false,
        },

        {
          isRead: true,
        }

      );

      res.json({

        message:
          "All notifications marked as read",

      });

    } catch (error) {

      res.status(500).json({

        error:
          error.message,

      });

    }

  }
);
// =====================================
// DELETE ONE NOTIFICATION
// =====================================

app.delete(
  "/api/notifications/:id",
  async (req, res) => {

    try {

      const notification =
        await Notification.findByIdAndDelete(
          req.params.id
        );

      if (!notification) {

        return res.status(404).json({
          message: "Notification not found",
        });

      }

      res.json({
        message: "Notification deleted successfully",
      });

    } catch (error) {

      console.log(
        "Delete Notification Error:",
        error
      );

      res.status(500).json({
        error: error.message,
      });

    }

  }
);


// =====================================
// DELETE ALL NOTIFICATIONS
// =====================================

app.delete(
  "/api/notifications",
  async (req, res) => {

    try {

      await Notification.deleteMany({});

      res.json({
        message: "All notifications deleted successfully",
      });

    } catch (error) {

      console.log(
        "Clear Notifications Error:",
        error
      );

      res.status(500).json({
        error: error.message,
      });

    }

  }
);


// =====================================
// GET AUTHOR
// =====================================

app.get(
  "/author",
  async (req, res) => {

    try {

      const author =
        await Author.findOne();

      if (!author) {

        return res.status(404).json({
          message: "Author not found",
        });

      }

      res.json(author);

    } catch (error) {

      console.log(
        "Author Error:",
        error
      );

      res.status(500).json({
        error: error.message,
      });

    }

  }
);


// =====================================
// GET AUTHOR API
// =====================================

app.get(
  "/api/author",
  async (req, res) => {

    try {

      const author =
        await Author.findOne();

      if (!author) {

        return res.status(404).json({
          message: "Author not found",
        });

      }

      res.json(author);

    } catch (error) {

      console.log(
        "Author API Error:",
        error
      );

      res.status(500).json({
        error: error.message,
      });

    }

  }
);


// =====================================
// SAVE / UPDATE AUTHOR
// =====================================

app.post(
  "/author",
  upload.single("image"),

  async (req, res) => {

    try {

      let author =
        await Author.findOne();

      if (!author) {

        author = new Author();

      }

      author.name =
        req.body.name || "";

      author.education =
        req.body.education || "";

      author.bio =
        req.body.bio || "";

      author.email =
        req.body.email || "";

      author.phone =
        req.body.phone || "";


      if (req.file) {

  const result = await cloudinary.uploader.upload(
    req.file.path,
    {
      folder: "mybookapp/authors",
    }
  );

  author.image = result.secure_url;

}


      await author.save();


      res.send(`

        <html>

        <head>

          <title>Author Saved</title>

          <style>

            body {
              font-family: Arial;
              background: #f5f5f5;
              text-align: center;
              padding: 50px;
            }

            .box {
              background: white;
              max-width: 500px;
              margin: auto;
              padding: 30px;
              border-radius: 15px;
              box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            }

            a {
              display: inline-block;
              margin: 8px;
              padding: 10px 18px;
              background: black;
              color: white;
              text-decoration: none;
              border-radius: 6px;
            }

          </style>

        </head>

        <body>

          <div class="box">

            <h2>
              Author Saved Successfully! ✅
            </h2>

            <p>
              Author:
              <b>${author.name}</b>
            </p>

            <br>

            <a href="/add-author">
              Edit Author
            </a>

            <a href="/author">
              View Author
            </a>

          </div>

        </body>

        </html>

      `);

    } catch (error) {

      console.log(
        "Author Save Error:",
        error
      );

      res.status(500).send(
        error.message
      );

    }

  }
);
// =====================================
// ADD / EDIT AUTHOR FORM
// =====================================

app.get("/add-author", async (req, res) => {

  try {

    const author = await Author.findOne();

    res.send(`

      <html>

      <head>

        <title>
          ${author ? "Edit Author" : "Add Author"}
        </title>

        <style>

          body {
            font-family: Arial;
            background: #f5f5f5;
            padding: 30px;
          }

          .container {
            max-width: 500px;
            margin: auto;
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
          }

          h2 {
            text-align: center;
          }

          input,
          textarea {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            margin-bottom: 15px;
            box-sizing: border-box;
          }

          textarea {
            min-height: 100px;
          }

          button {
            width: 100%;
            padding: 12px;
            background: black;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
          }

          a {
            display: block;
            text-align: center;
            margin-top: 15px;
            color: #333;
          }

        </style>

      </head>

      <body>

        <div class="container">

          <h2>
            ${author ? "Edit Author" : "Add Author"}
          </h2>

          <form
            method="POST"
            action="/author"
            enctype="multipart/form-data"
          >

            <label>
              Author Name:
            </label>

            <input
              type="text"
              name="name"
              value="${author?.name || ""}"
              required
            >


            <label>
              Education:
            </label>

            <input
              type="text"
              name="education"
              value="${author?.education || ""}"
            >


            <label>
              Bio:
            </label>

            <textarea
              name="bio"
            >${author?.bio || ""}</textarea>


            <label>
              Email:
            </label>

            <input
              type="email"
              name="email"
              value="${author?.email || ""}"
            >


            <label>
              Phone:
            </label>

            <input
              type="text"
              name="phone"
              value="${author?.phone || ""}"
            >


            <label>
              Author Image:
            </label>

            <input
              type="file"
              name="image"
              accept="image/*"
            >


            <button type="submit">
              Save Author
            </button>

          </form>


          <a href="/author">
            View Author
          </a>

        </div>

      </body>

      </html>

    `);

  } catch (error) {

    console.log(
      "Add Author Page Error:",
      error
    );

    res.status(500).send(
      error.message
    );

  }

});