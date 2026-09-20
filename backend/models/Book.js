const mongoose = require("mongoose");

const bookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },

  author: {
    type: String,
    required: true,
  },

  // Har book ka apna author data
  authorDetails: {
    name: {
      type: String,
      default: "",
    },

    education: {
      type: String,
      default: "",
    },

    bio: {
      type: String,
      default: "",
    },

    image: {
      type: String,
      default: "",
    },

    email: {
      type: String,
      default: "",
    },

    phone: {
      type: String,
      default: "",
    },
  },

  price: {
    type: Number,
    required: true,
  },

  description: {
    type: String,
    default: "",
  },

  coverImage: {
    type: String,
    default: "",
  },

  frontImage: {
    type: String,
    default: "",
  },

  backImage: {
    type: String,
    default: "",
  },

  // Home screen category
  category: {
    type: String,
    enum: [
      "favourite",
      "new_release",
      "trending",
    ],
    default: null,
  },

  // Amazon book link
  amazonUrl: {
    type: String,
    default: "",
    trim: true,
  },

  // Book available inside AJ Reads
  appBookEnabled: {
    type: Boolean,
    default: false,
  },

  // Free book or paid book
  isFree: {
    type: Boolean,
    default: false,
  },

  // PDF book URL
  pdfUrl: {
    type: String,
    default: "",
    trim: true,
  },
});

module.exports = mongoose.model(
  "Book",
  bookSchema
);