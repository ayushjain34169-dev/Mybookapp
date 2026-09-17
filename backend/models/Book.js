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
});

module.exports = mongoose.model("Book", bookSchema);