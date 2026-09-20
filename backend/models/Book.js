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
  enum: ["favourite", "new_release", "trending"],
  default: null,
},
amazonUrl: {
    type: String,
    default: "",
    trim: true,
  },

  appBookEnabled: {
    type: Boolean,
    default: false,
  },

  isFree: {
    type: Boolean,
    default: false,
  },
});

module.exports = mongoose.model("Book", bookSchema);