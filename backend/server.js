const fs = require("fs");
require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const multer = require("multer");
const cloudinary = require("cloudinary").v2;

const { createClient } = require("@supabase/supabase-js");

const Book = require("./models/Book");
const Author = require("./models/author");
const Notification = require("./models/notification");
const Favourite = require("./models/Favourite");

const app = express();

// =====================================
// CLOUDINARY
// =====================================

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// =====================================
// SUPABASE
// =====================================

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SECRET_KEY
);

// =====================================
// MULTER
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
  storage,
  limits: {
    fileSize: 100 * 1024 * 1024,
  },
});

// =====================================
// MIDDLEWARE
// =====================================

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads"));

// =====================================
// MONGODB
// =====================================

mongoose
  .connect(
    process.env.MONGODB_URI ||
      "mongodb://127.0.0.1:27017/mybookapp",
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
    console.error("MongoDB Connection Error:", error);
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
    const books = await Book.find().sort({ createdAt: -1 });
    res.json(books);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
});

// =====================================
// ADD FAVOURITE
// =====================================

app.post("/favourites", async (req, res) => {
  try {
    const { userId, bookId } = req.body;

    if (!userId || !bookId) {
      return res.status(400).json({
        success: false,
        message: "userId and bookId are required",
      });
    }

    const favourite = await Favourite.create({
      userId,
      bookId,
    });

    res.json({
      success: true,
      message: "Book added to favourites",
      favourite,
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: "Book already in favourites",
      });
    }

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// =====================================
// REMOVE FAVOURITE
// =====================================

app.delete("/favourites", async (req, res) => {
  try {
    const { userId, bookId } = req.body;

    if (!userId || !bookId) {
      return res.status(400).json({
        success: false,
        message: "userId and bookId are required",
      });
    }

    const result = await Favourite.findOneAndDelete({
      userId,
      bookId,
    });

    res.json({
      success: true,
      message: result
        ? "Book removed from favourites"
        : "Book was not in favourites",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// =====================================
// GET USER FAVOURITES
// =====================================

app.get("/favourites/:userId", async (req, res) => {
  try {
    const favourites = await Favourite.find({
      userId: req.params.userId,
    }).populate("bookId");

    res.json({
      success: true,
      favourites,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// =====================================
// CHECK FAVOURITE
// =====================================

app.get("/favourites/check", async (req, res) => {
  try {
    const { userId, bookId } = req.query;

    if (!userId || !bookId) {
      return res.status(400).json({
        success: false,
        message: "userId and bookId are required",
      });
    }

    const favourite = await Favourite.findOne({
      userId,
      bookId,
    });

    res.json({
      success: true,
      isFavourite: !!favourite,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// =====================================
// UPDATE BOOK CATEGORY
// =====================================

app.put("/books/:id/category", async (req, res) => {
  try {
    const { category } = req.body;

    const allowedCategories = [
      null,
      "new_release",
      "trending",
    ];

    if (!allowedCategories.includes(category)) {
      return res.status(400).json({
        success: false,
        message: "Invalid category",
      });
    }

    const book = await Book.findByIdAndUpdate(
      req.params.id,
      { category },
      { new: true }
    );

    if (!book) {
      return res.status(404).json({
        success: false,
        message: "Book not found",
      });
    }

    res.json({
      success: true,
      message: "Book category updated successfully",
      book,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// =====================================
// REMOVE OLD FAVOURITE CATEGORY
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
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});
// =====================================
// DELETE BOOK PAGE
// =====================================

app.get("/delete-book", async (req, res) => {
  try {
    const books = await Book.find().sort({ createdAt: -1 });

    const bookList =
      books.length > 0
        ? books
            .map(
              (book) => `
        <div class="book">
          <div>
            <h3>${book.title || ""}</h3>
            <p><b>Author:</b> ${book.author || ""}</p>
            <p><b>Price:</b> ₹${book.price || 0}</p>
            <p><b>ID:</b> ${book._id}</p>
          </div>

          <form
            method="POST"
            action="/delete-book/${book._id}"
            onsubmit="return confirm('Kya aap is book ko permanently delete karna chahte hain?');"
          >
            <button type="submit">Delete Book</button>
          </form>
        </div>
      `
            )
            .join("")
        : `<div class="empty"><h3>No books found</h3></div>`;

    res.send(`
<!DOCTYPE html>
<html>
<head>
<title>Delete Books</title>
<style>
body{
  font-family:Arial;
  background:#f5f5f5;
  padding:30px;
}
.container{
  max-width:800px;
  margin:auto;
}
h1{text-align:center}
.book{
  background:white;
  padding:20px;
  margin:15px 0;
  border-radius:12px;
  box-shadow:0 4px 12px rgba(0,0,0,.1);
  display:flex;
  justify-content:space-between;
  align-items:center;
  gap:20px;
}
button{
  background:#d32f2f;
  color:white;
  border:0;
  padding:11px 18px;
  border-radius:6px;
  cursor:pointer;
}
.links{
  text-align:center;
  margin-top:25px;
}
.links a{
  display:inline-block;
  margin:5px;
  padding:10px 18px;
  background:#000;
  color:#fff;
  text-decoration:none;
  border-radius:6px;
}
.empty{
  background:white;
  padding:30px;
  text-align:center;
  border-radius:12px;
}
</style>
</head>

<body>

<div class="container">

<h1>Delete Books</h1>

<p style="text-align:center;color:#666">
Developer Book Management
</p>

${bookList}

<div class="links">
<a href="/add-book">Add New Book</a>
<a href="/books">View Books API</a>
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
// DELETE BOOK
// =====================================

app.post("/delete-book/:id", async (req, res) => {
  try {
    const book = await Book.findByIdAndDelete(req.params.id);

    if (!book) {
      return res.status(404).send("Book not found");
    }

    res.send(`
<html>
<head>
<title>Book Deleted</title>
</head>

<body style="font-family:Arial;text-align:center;padding:50px">

<h2>Book Deleted Successfully! ✅</h2>

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
    res.status(500).send(error.message);
  }
});

// =====================================
// ADD BOOK FORM
// =====================================

app.get("/add-book", (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>

<head>

<title>Add Book</title>

<style>

body{
  font-family:Arial;
  background:#f5f5f5;
  padding:30px;
}

.container{
  max-width:550px;
  margin:auto;
  background:white;
  padding:25px;
  border-radius:12px;
  box-shadow:0 4px 15px rgba(0,0,0,.1);
}

h2{
  text-align:center;
  color:#5B4BDB;
}

label{
  display:block;
  margin-top:12px;
  margin-bottom:6px;
  font-weight:bold;
}

input,
textarea,
select{
  width:100%;
  padding:10px;
  margin-bottom:15px;
  box-sizing:border-box;
  border:1px solid #ddd;
  border-radius:7px;
}

textarea{
  min-height:100px;
}

.option-box{
  background:#f7f8fc;
  padding:15px;
  border-radius:10px;
  margin-bottom:18px;
}

.option-row{
  display:flex;
  align-items:center;
  gap:10px;
  margin:10px 0;
}

.option-row input{
  width:auto;
  margin:0;
}

.option-row label{
  margin:0;
  font-weight:normal;
}

button{
  width:100%;
  padding:12px;
  background:#5B4BDB;
  color:white;
  border:0;
  border-radius:7px;
  font-size:16px;
  font-weight:bold;
  cursor:pointer;
}

</style>

</head>

<body>

<div class="container">

<h2>📚 Add New Book</h2>

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

<input
type="text"
name="authorName"
required
>

<label>Education:</label>

<input
type="text"
name="authorEducation"
placeholder="MCA, BCA etc."
>

<label>Author Bio:</label>

<textarea
name="authorBio"
placeholder="About the author..."
></textarea>

<label>Author Email:</label>

<input
type="email"
name="authorEmail"
>

<label>Author Phone:</label>

<input
type="text"
name="authorPhone"
>

<label>Author Image:</label>

<input
type="file"
name="authorImage"
accept="image/*"
required
>

<label>Price:</label>

<input
type="number"
name="price"
required
>

<label>Description:</label>

<textarea name="description"></textarea>

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

<label>Book PDF:</label>

<input
type="file"
name="bookPdf"
accept="application/pdf"
required
>

<small>
AJ Reads mein read karne ke liye book ki PDF upload karein.
</small>

<br><br>

<label>Book Category:</label>

<select name="category">

<option value="">No Category</option>

<option value="new_release">
🆕 New Release
</option>

<option value="trending">
🔥 Trending
</option>

</select>

<div class="option-box">

<h3>📖 Book Access</h3>

<div class="option-row">

<input
type="checkbox"
id="appBookEnabled"
name="appBookEnabled"
value="true"
>

<label for="appBookEnabled">
Available to Read in AJ Reads
</label>

</div>

<div class="option-row">

<input
type="checkbox"
id="isFree"
name="isFree"
value="true"
>

<label for="isFree">
🆓 Free Book
</label>

</div>

</div>

<div class="option-box">

<h3>🛒 Amazon</h3>

<label>Amazon Book URL</label>

<input
type="url"
name="amazonUrl"
placeholder="https://amzn.in/..."
>

<small>
Amazon par book available ho to uska URL yahan paste karein.
</small>

</div>

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
// SAVE BOOK
// =====================================

app.post(
  "/add-book",
  upload.fields([
    { name: "coverImage", maxCount: 1 },
    { name: "frontImage", maxCount: 1 },
    { name: "backImage", maxCount: 1 },
    { name: "authorImage", maxCount: 1 },
    { name: "bookPdf", maxCount: 1 },
  ]),
  async (req, res) => {
    try {
      let coverImageUrl = "";
      let frontImageUrl = "";
      let backImageUrl = "";
      let authorImageUrl = "";
      let pdfUrl = "";

      // =================================
      // COVER IMAGE
      // =================================

      if (req.files?.coverImage?.[0]) {
        const result = await cloudinary.uploader.upload(
          req.files.coverImage[0].path,
          {
            folder: "mybookapp/books",
          }
        );

        coverImageUrl = result.secure_url;
      }

      // =================================
      // FRONT IMAGE
      // =================================

      if (req.files?.frontImage?.[0]) {
        const result = await cloudinary.uploader.upload(
          req.files.frontImage[0].path,
          {
            folder: "mybookapp/books",
          }
        );

        frontImageUrl = result.secure_url;
      }

      // =================================
      // BACK IMAGE
      // =================================

      if (req.files?.backImage?.[0]) {
        const result = await cloudinary.uploader.upload(
          req.files.backImage[0].path,
          {
            folder: "mybookapp/books",
          }
        );

        backImageUrl = result.secure_url;
      }

      // =================================
      // AUTHOR IMAGE
      // =================================

      if (req.files?.authorImage?.[0]) {
        const result = await cloudinary.uploader.upload(
          req.files.authorImage[0].path,
          {
            folder: "mybookapp/authors",
          }
        );

        authorImageUrl = result.secure_url;
      }

      // =================================
      // PDF → SUPABASE
      // =================================

      if (req.files?.bookPdf?.[0]) {
        const pdfFile = req.files.bookPdf[0];

        const fileName =
          Date.now() +
          "-" +
          pdfFile.originalname.replace(/\s+/g, "-");

        const fileBuffer = fs.readFileSync(
          pdfFile.path
        );

        const { error } =
          await supabase.storage
            .from("book-pdfs")
            .upload(
              fileName,
              fileBuffer,
              {
                contentType: "application/pdf",
                upsert: false,
              }
            );

        if (error) {
          console.error(
            "Supabase PDF Upload Error:",
            error
          );

          throw error;
        }

        const { data } =
          supabase.storage
            .from("book-pdfs")
            .getPublicUrl(fileName);

        pdfUrl = data.publicUrl;
      }

      // =================================
      // CREATE BOOK
      // =================================

      const book = new Book({

        title: req.body.title || "",

        author: req.body.authorName || "",

        authorDetails: {
          name: req.body.authorName || "",
          education:
            req.body.authorEducation || "",
          bio:
            req.body.authorBio || "",
          image: authorImageUrl,
          email:
            req.body.authorEmail || "",
          phone:
            req.body.authorPhone || "",
        },

        price: req.body.price || 0,

        description:
          req.body.description || "",

        coverImage: coverImageUrl,

        frontImage: frontImageUrl,

        backImage: backImageUrl,

        category:
          req.body.category || null,

        amazonUrl:
          req.body.amazonUrl || "",

        appBookEnabled:
          req.body.appBookEnabled === "true",

        isFree:
          req.body.isFree === "true",

        pdfUrl: pdfUrl,
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
<!DOCTYPE html>

<html>

<head>

<title>Book Added</title>

<style>

body{
font-family:Arial;
text-align:center;
padding:50px;
background:#f5f5f5;
}

.box{
background:white;
max-width:500px;
margin:auto;
padding:30px;
border-radius:15px;
box-shadow:0 4px 15px rgba(0,0,0,.1);
}

a{
display:inline-block;
margin:8px;
padding:10px 18px;
background:black;
color:white;
text-decoration:none;
border-radius:6px;
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

      console.error(
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
// CREATE OFFER API
// =====================================

app.post(
  "/api/notifications/offer",
  async (req, res) => {
    try {

      const { title, message } = req.body;

      const notification =
        await Notification.create({

          title:
            title ||
            "Special Offer 🎁",

          message:
            message ||
            "A special offer is available for you.",

          type: "offer",

          isRead: false,

        });

      res.status(201).json(
        notification
      );

    } catch (error) {

      console.error(
        "Offer Error:",
        error
      );

      res.status(500).json({
        message:
          "Offer notification create nahi hui",
      });
    }
  }
);

// =====================================
// SPECIAL OFFER ADMIN PAGE
// =====================================

app.get(
  "/add-offer",
  async (req, res) => {

    try {

      const offers =
        await Notification.find({
          type: "offer",
        }).sort({
          createdAt: -1,
        });

      const offerList =
        offers
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

body{
font-family:Arial;
background:#f7f8fc;
padding:30px;
}

.container{
max-width:700px;
margin:auto;
}

.box,
.offer{
background:white;
padding:20px;
border-radius:15px;
box-shadow:0 4px 15px rgba(0,0,0,.08);
}

h1{
color:#5B4BDB;
}

input,
textarea{
width:100%;
box-sizing:border-box;
padding:12px;
border:1px solid #ddd;
border-radius:10px;
margin:8px 0 15px;
}

textarea{
height:100px;
resize:vertical;
}

.add-button{
width:100%;
padding:13px;
border:0;
border-radius:10px;
background:#5B4BDB;
color:white;
font-size:16px;
font-weight:bold;
}

.offer{
margin-top:15px;
}

.offer h3{
margin:0;
}

.offer p{
color:#666;
}

.buttons{
display:flex;
gap:10px;
align-items:center;
}

.edit{
background:#5B4BDB;
color:white;
padding:8px 14px;
border-radius:8px;
text-decoration:none;
}

.delete{
background:#e53935;
color:white;
padding:8px 14px;
border:0;
border-radius:8px;
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

<label>Offer Title</label>

<input
type="text"
name="title"
placeholder="Special Book Offer 🎁"
required
>

<label>Offer Message</label>

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

<h2>Existing Offers</h2>

${
  offerList ||
  "<p>No offers available.</p>"
}

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
  }
);

// =====================================
// EDIT OFFER PAGE
// =====================================

app.get(
  "/edit-offer/:id",
  async (req, res) => {

    try {

      const offer =
        await Notification.findById(
          req.params.id
        );

      if (
        !offer ||
        offer.type !== "offer"
      ) {
        return res
          .status(404)
          .send("Offer nahi mila.");
      }

      res.send(`
<!DOCTYPE html>

<html>

<head>

<title>Edit Special Offer</title>

<style>

body{
font-family:Arial;
background:#f7f8fc;
padding:40px;
}

.box{
max-width:500px;
margin:auto;
background:white;
padding:30px;
border-radius:18px;
box-shadow:0 5px 20px rgba(0,0,0,.08);
}

input,
textarea{
width:100%;
box-sizing:border-box;
padding:12px;
border:1px solid #ddd;
border-radius:10px;
margin:8px 0 15px;
}

textarea{
height:120px;
}

button{
width:100%;
padding:13px;
border:0;
border-radius:10px;
background:#5B4BDB;
color:white;
font-size:16px;
font-weight:bold;
}

</style>

</head>

<body>

<div class="box">

<h2>✏️ Edit Special Offer</h2>

<form
method="POST"
action="/edit-offer/${offer._id}"
>

<label>Offer Title</label>

<input
type="text"
name="title"
value="${offer.title}"
required
>

<label>Offer Message</label>

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
  }
);

// =====================================
// UPDATE OFFER
// =====================================

app.post(
  "/edit-offer/:id",
  async (req, res) => {

    try {

      const {
        title,
        message,
      } = req.body;

      await Notification.findByIdAndUpdate(
        req.params.id,
        {
          title,
          message,
        },
        {
          new: true,
        }
      );

      res.redirect(
        "/add-offer"
      );

    } catch (error) {

      console.error(
        "Update Offer Error:",
        error
      );

      res.status(500).send(
        "Offer update nahi hui."
      );
    }
  }
);

// =====================================
// DELETE OFFER
// =====================================

app.post(
  "/delete-offer/:id",
  async (req, res) => {

    try {

      await Notification.findByIdAndDelete(
        req.params.id
      );

      res.redirect(
        "/add-offer"
      );

    } catch (error) {

      console.error(
        "Delete Offer Error:",
        error
      );

      res.status(500).send(
        "Offer delete nahi hui."
      );
    }
  }
);

// =====================================
// SAVE OFFER
// =====================================

app.post(
  "/add-offer",
  async (req, res) => {

    try {

      const {
        title,
        message,
      } = req.body;

      await Notification.create({

        title,

        message,

        type: "offer",

        isRead: false,

      });

      res.send(`
<html>

<head>

<title>Offer Added</title>

</head>

<body
style="
font-family:Arial;
text-align:center;
padding:50px;
"
>

<h2>
✅ Special Offer Added Successfully!
</h2>

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

      console.error(
        "Offer Save Error:",
        error
      );

      res.status(500).send(`
<h2>❌ Special Offer add nahi hui</h2>
<p>Please server terminal check karein.</p>
`);
    }
  }
);

// =====================================
// GET ALL NOTIFICATIONS
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

      res.json(
        notifications
      );

    } catch (error) {

      res.status(500).json({
        error: error.message,
      });
    }
  }
);

// =====================================
// UNREAD COUNT
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
        count,
      });

    } catch (error) {

      res.status(500).json({
        error: error.message,
      });
    }
  }
);

// =====================================
// MARK ONE READ
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

      res.json(
        notification
      );

    } catch (error) {

      res.status(500).json({
        error: error.message,
      });
    }
  }
);

// =====================================
// MARK ALL READ
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
        error: error.message,
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
          message:
            "Notification not found",
        });
      }

      res.json({
        message:
          "Notification deleted successfully",
      });

    } catch (error) {

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
        message:
          "All notifications deleted successfully",
      });

    } catch (error) {

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
          message:
            "Author not found",
        });
      }

      res.json(author);

    } catch (error) {

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
          message:
            "Author not found",
        });
      }

      res.json(author);

    } catch (error) {

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

      // ================================
      // AUTHOR IMAGE
      // ================================

      if (req.file) {

        const result =
          await cloudinary.uploader.upload(
            req.file.path,
            {
              folder:
                "mybookapp/authors",
            }
          );

        author.image =
          result.secure_url;
      }

      await author.save();

      res.send(`
<!DOCTYPE html>

<html>

<head>

<title>Author Saved</title>

<style>

body{
font-family:Arial;
background:#f5f5f5;
text-align:center;
padding:50px;
}

.box{
background:white;
max-width:500px;
margin:auto;
padding:30px;
border-radius:15px;
box-shadow:0 4px 15px rgba(0,0,0,.1);
}

a{
display:inline-block;
margin:8px;
padding:10px 18px;
background:black;
color:white;
text-decoration:none;
border-radius:6px;
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

      console.error(
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

app.get(
  "/add-author",
  async (req, res) => {

    try {

      const author =
        await Author.findOne();

      res.send(`
<!DOCTYPE html>

<html>

<head>

<title>
${author ? "Edit Author" : "Add Author"}
</title>

<style>

body{
font-family:Arial;
background:#f5f5f5;
padding:30px;
}

.container{
max-width:500px;
margin:auto;
background:white;
padding:25px;
border-radius:12px;
box-shadow:0 4px 15px rgba(0,0,0,.1);
}

h2{
text-align:center;
}

input,
textarea{
width:100%;
padding:10px;
margin-top:6px;
margin-bottom:15px;
box-sizing:border-box;
}

textarea{
min-height:100px;
}

button{
width:100%;
padding:12px;
background:black;
color:white;
border:0;
border-radius:6px;
font-size:16px;
}

a{
display:block;
text-align:center;
margin-top:15px;
color:#333;
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

      console.error(
        "Add Author Page Error:",
        error
      );

      res.status(500).send(
        error.message
      );
    }
  }
);