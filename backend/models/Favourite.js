const mongoose = require("mongoose");

const favouriteSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      trim: true,
    },

    bookId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Book",
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Same user same book ko duplicate favourite nahi kar sakta
favouriteSchema.index(
  { userId: 1, bookId: 1 },
  { unique: true }
);

module.exports = mongoose.model(
  "Favourite",
  favouriteSchema
);